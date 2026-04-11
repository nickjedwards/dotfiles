import { With, createBinding, createComputed, createState, onCleanup } from 'ags'
import AstalApps from 'gi://AstalApps'
import AstalMpris from 'gi://AstalMpris'

export default function Mpris() {
  const mpris = AstalMpris.get_default()
  const apps = new AstalApps.Apps()

  const [players, setPlayers] = createState(mpris.players)

  const refresh = () => setPlayers([...mpris.players])

  const ids = [mpris.connect('player-added', refresh), mpris.connect('player-closed', refresh)]
  onCleanup(() => ids.forEach((id) => mpris.disconnect(id)))

  const active = createComputed(
    () => players().find((p) => p.playbackStatus === AstalMpris.PlaybackStatus.PLAYING) ?? players()[0] ?? null
  )

  return (
    <box class="mpris">
      <With value={active}>
        {(player) => {
          if (!player) return <label class="empty" label="Nothing playing" />

          const [app] = apps.exact_query(player.entry)

          const title = createBinding(player, 'title')
          const artist = createBinding(player, 'artist')
          const status = createBinding(player, 'playbackStatus')

          const label = createComputed(() => `${title() ?? 'Unknown'} — ${artist() ?? ''}`)

          return (
            <button onClicked={() => player.play_pause()}>
              <box spacing={7}>
                <image visible={!!app.iconName} iconName={app?.iconName} />
                <label maxWidthChars={30} ellipsize={3} label={label} tooltipText={label} />
                <image
                  iconName={status((s) =>
                    s === AstalMpris.PlaybackStatus.PLAYING
                      ? 'media-playback-pause-symbolic'
                      : 'media-playback-start-symbolic'
                  )}
                />
              </box>
            </button>
          )
        }}
      </With>
    </box>
  )
}
