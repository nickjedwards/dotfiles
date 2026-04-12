import { For, createBinding, createComputed, createMemo, createState } from 'ags'
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
} as const

export default function Workspace() {
  const hyprland = Hyprland.get_default()
  const focusedWorkspace = createBinding(hyprland, 'focusedWorkspace')
  const clients = createBinding(hyprland, 'clients')
  const [urgents, setUrgents] = createState<Set<string>>(new Set())

  hyprland.connect('urgent', (_, client) => {
    if (!client) return

    setUrgents((prev) => new Set(prev).add(client.address))
  })

  hyprland.connect('notify::focused-workspace', () => {
    const fws = focusedWorkspace()

    if (!fws) return

    setUrgents((prev) => {
      const next = new Set(prev)

      for (const { workspace, address } of clients()) {
        if (workspace.id === fws.id) next.delete(address)
      }

      return next
    })
  })

  const sort = (ws: Hyprland.Workspace[]) => {
    const ids = new Set([1, 2, 3, 4, 5, ...ws.map((w) => w.id)])

    return [...ids].sort((a, b) => a - b)
  }

  return (
    <box class="workspaces" spacing={7}>
      <For each={createBinding(hyprland, 'workspaces')(sort)}>
        {(id: number) => {
          const ws = hyprland.get_workspace(id)

          const classes = createMemo(() => {
            const list: string[] = []
            const isActive = focusedWorkspace.as((fws) => fws.id === id)
            const wsClients = clients().filter((c) => c.workspace.id === id)
            const isUrgent = !isActive() && wsClients.some((c) => urgents().has(c.address))

            if (isActive()) list.push('active')
            if (!wsClients.length) list.push('empty')
            if (isUrgent) list.push('urgent')

            return list
          })

          const label = createComputed(() =>
            classes().includes('urgent') ? '' : (ICONS[id as keyof typeof ICONS] ?? '')
          )

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
