import { With, createBinding } from 'ags'
import Battery from 'gi://AstalBattery'
import Network from 'gi://AstalNetwork'
import Wp from 'gi://AstalWp'

export default function QuickSettings() {
  const { defaultSpeaker: speaker } = Wp.get_default()
  const mute = createBinding(speaker, 'mute')

  const network = Network.get_default()
  const wifi = createBinding(network, 'wifi')

  const battery = Battery.get_default()

  return (
    <button class="quick-settings" onClicked={() => speaker.set_mute(!mute())}>
      <box spacing={12}>
        <image class="audio" iconName={createBinding(speaker, 'volumeIcon')} />
        <With value={wifi}>
          {(wifi) => wifi && <image class="network" iconName={createBinding(wifi, 'iconName')} />}
        </With>
        <image class="battery" iconName={createBinding(battery, 'iconName')} />
      </box>
    </button>
  )
}
