# PI Target

A small World of Warcraft addon for Priests that sets and shows your Power
Infusion target.

It keeps a macro called `PI` pointed at one player, and shows who that is in a
small frame, coloured by their class (red if they've left the group).

```
#showtooltip
/cast [@mouseover,help,nodead][@<target>,exists,nodead][] Power Infusion
/use 13
```

## Install

Download `PITarget-x.y.z.zip` from the latest release and unzip it into
`World of Warcraft/_retail_/Interface/AddOns`, so you end up with
`AddOns/PITarget/PITarget.toc`.

## Use

| Command           | What it does                                                                                                |
| ----------------- | ----------------------------------------------------------------------------------------------------------- |
| `/pit set`        | Point the macro at your current target (a friendly player), or yourself with no target. Out of combat only. |
| `/pit set <unit>` | Point the macro at another unit, such as `mouseover` or `focus`. Out of combat only.                        |
| `/pit lock`       | Lock the frame in place and make it click-through.                                                          |
| `/pit unlock`     | Let the frame be dragged again.                                                                             |
| `/pit reset`      | Move the frame back to the middle of the screen.                                                            |
| `/pit debug`      | Print the frame's state and the macro's target.                                                             |

The first `/pit set` creates the macro if it doesn't exist; drag it to your
bars from `/macro`. The look (size, colours, font) and the trinket line are
set at the top of `PITarget.lua`. It uses a LibSharedMedia font if you name
one there, and is styled to sit alongside EllesmereUI.

## Click casting

With a click-casting addon (Clique, Cell, VuhDo, Grid2 …) you can set or cast
PI by clicking a unit frame:

- **Set the PI target:** add a macro binding that runs `/pit set mouseover`. Clicking
  a party or raid frame with it points the `PI` macro at that player. This
  only works out of combat, like `/pit set`.
- **Cast PI:** bind the `PI` macro, or the Power Infusion spell. The macro casts
  on the frame you click, because `@mouseover` comes first.

## Releases

[release-please](https://github.com/googleapis/release-please) reads commit
messages, so they follow [Conventional Commits](https://www.conventionalcommits.org)
(`feat:`, `fix:`, `chore:` …). Merging its "chore: release x.y.z" pull request
bumps the version in `PITarget.toc`, tags the release and attaches the zip.
