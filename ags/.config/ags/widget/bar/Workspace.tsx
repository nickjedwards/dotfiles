import { For, createBinding, createMemo } from 'ags'
import Hyprland from 'gi://AstalHyprland'

const TOOLTIPS = {
  1: 'Terminal',
  2: 'Code',
  3: 'Browse',
  4: 'Music',
  5: 'Chat',
} as const

const ICONS = {
  1: '',
  2: '󰨞',
  3: '',
  4: '',
  5: '󰍦',
  6: '󰲪',
  7: '󰲬',
  8: '󰲮',
  9: '󰲰',
  10: '󰿬',
  // urgent: '',
} as const

export default function Workspace() {
  const hyprland = Hyprland.get_default()
  const focusedWorkspace = createBinding(hyprland, 'focusedWorkspace')
  const clients = createBinding(hyprland, 'clients')

  const sort = (ws: Hyprland.Workspace[]) => {
    const ids = new Set([1, 2, 3, 4, 5, ...ws.map((w) => w.id)])

    return [...ids].sort((a, b) => a - b)
  }

  return (
    <box cssClasses={['workspaces']} spacing={7}>
      <For each={createBinding(hyprland, 'workspaces')(sort)}>
        {(id: number) => {
          const ws = hyprland.get_workspace(id)

          const classes = createMemo(() => {
            const list = []
            const isActive = focusedWorkspace.as((fws) => fws.id === id)
            const isOccupied = clients().some((c) => c.workspace.id == id)

            if (isActive()) list.push('active')
            if (!isOccupied) list.push('empty')

            return list
          })
          const label = ICONS[id as keyof typeof ICONS] ?? ''

          return (
            <button
              cssClasses={classes}
              onClicked={() => {
                if (ws) ws.focus()
                else hyprland.dispatch('workspace', String(id))
              }}
              label={label}
              tooltipText={TOOLTIPS[id as keyof typeof TOOLTIPS] ?? `Workspace ${id}`}
            />
          )
        }}
      </For>
    </box>
  )
}
