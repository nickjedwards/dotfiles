import { createState } from 'ags'
import app from 'ags/gtk4/app'
import { execAsync } from 'ags/process'
import { createPoll } from 'ags/time'
import GLib from 'gi://GLib'

const [inhibited, setInhibited] = createState(false)

// Reset on reload so UI matches reality
execAsync('pkill -CONT hypridle').catch(() => void 0)

function toggleIdle() {
  const next = !inhibited.peek()

  execAsync(`pkill ${next ? '-STOP' : '-CONT'} hypridle`)
    .then(() => setInhibited(next))
    .catch((error) => console.error('idle inhibitor:', error))
}

export default function Clock({ format = '%H:%M' }: { format: string }) {
  const time = createPoll('', 1000, () => GLib.DateTime.new_now_local().format(format) ?? '')

  return (
    <box class="idle-clock">
      <button
        class={inhibited((v) => (v ? 'idle active' : 'idle'))}
        tooltipText={inhibited((v) => (v ? 'Activated' : 'Deactivated'))}
        onClicked={toggleIdle}
      >
        <label label={inhibited((v) => (v ? '󰅶' : '󰛊'))} />
      </button>

      <button class="clock" onClicked={() => app.toggle_window('ndvr-left-panel')}>
        <label label={time} />
      </button>
    </box>
  )
}
