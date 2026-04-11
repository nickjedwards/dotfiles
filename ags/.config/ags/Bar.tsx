import { onCleanup } from 'ags'
import app from 'ags/gtk4/app'
import Astal from 'gi://Astal?version=4.0'
import Gdk from 'gi://Gdk?version=4.0'
import Gtk from 'gi://Gtk?version=4.0'

import { Clock, Mpris, Pacman, QuickSettings, Workspace } from './widget/bar'

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const { TOP } = Astal.WindowAnchor

  return (
    <window
      $={(self) => onCleanup(() => self.destroy())}
      visible
      name="ndvr-bar"
      namespace="ndvr-bar"
      class="panel"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP}
      layer={Astal.Layer.TOP}
      application={app}
    >
      <centerbox orientation={Gtk.Orientation.HORIZONTAL} hexpand vexpand={false} valign={Gtk.Align.CENTER}>
        <box $type="start" hexpand spacing={7}>
          <Clock format="%H:%M" />
          <Workspace />
          <Mpris />
        </box>
        <box $type="end" spacing={7}>
          <Pacman />
          <QuickSettings />
        </box>
      </centerbox>
    </window>
  )
}
