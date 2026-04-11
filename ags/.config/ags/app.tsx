import { For, This, createBinding } from 'ags'
import { Gtk } from 'ags/gtk4'
import app from 'ags/gtk4/app'
import Astal from 'gi://Astal?version=4.0'

import Bar from './Bar'
import Panel from './Panel'
import css from './theme/style.scss'
import { Calendar } from './widget/panel'

app.start({
  css,
  main() {
    const monitors = createBinding(app, 'monitors')
    const { TOP, LEFT, BOTTOM } = Astal.WindowAnchor

    return (
      <For each={monitors}>
        {(monitor) => (
          <This this={app}>
            <Bar gdkmonitor={monitor} />

            <Panel name="ndvr-left-panel" anchor={TOP | LEFT | BOTTOM} gdkmonitor={monitor}>
              <box widthRequest={400} orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <Calendar />
              </box>
            </Panel>
          </This>
        )}
      </For>
    )
  },
})
