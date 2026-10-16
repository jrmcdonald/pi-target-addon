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

| Command       | What it does                                                                                                |
| ------------- | ----------------------------------------------------------------------------------------------------------- |
| `/pit set`    | Point the macro at your current target (a friendly player), or yourself with no target. Out of combat only. |
| `/pit lock`   | Lock the frame in place and make it click-through.                                                          |
| `/pit unlock` | Let the frame be dragged again.                                                                             |
| `/pit reset`  | Move the frame back to the middle of the screen.                                                            |
| `/pit debug`  | Print the frame's state and the macro's target.                                                             |

The first `/pit set` creates the macro if it doesn't exist; drag it to your
bars from `/macro`. The look (size, colours, font) and the trinket line are
set at the top of `PITarget.lua`. It uses a LibSharedMedia font if you name
one there, and is styled to sit alongside EllesmereUI.

## Releases

[release-please](https://github.com/googleapis/release-please) reads commit
messages, so they follow [Conventional Commits](https://www.conventionalcommits.org)
(`feat:`, `fix:`, `chore:` …). Merging its "chore: release x.y.z" pull request
bumps the version in `PITarget.toc`, tags the release and attaches the zip.
