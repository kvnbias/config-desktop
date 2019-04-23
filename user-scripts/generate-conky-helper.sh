
#!/bin/bash
# ~/.config/conky/generate-conky-helper.sh '#ffffff'

generate_conky_helper() {
    echo '

-- vim: ts=4 sw=4 noet ai cindent syntax=lua
--[[
/etc/conky/helper.conf
]]

conky.config = {
    update_interval = 1,
    cpu_avg_samples = 2,
    net_avg_samples = 2,
    out_to_console = false,
    override_utf8_locale = true,
    double_buffer = true,
    no_buffers = true,
    text_buffer_size = 32768,
    imlib_cache_size = 0,
    background = true,
    own_window = true,
    own_window_type = "override",
    own_window_argb_visual = "yes",
    own_window_transparent = true,
    own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",
    border_inner_margin = 5,
    border_outer_margin = 0,
    xinerama_head = 1,
    gap_x = 32,
    gap_y = 32,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,
    use_xft = true,
    font = "Monospace:size=10",
    xftalpha = 0.8,
    uppercase = false,
    default_color = "'$1'",
    minimum_width = 300, minimum_height = 0,
    alignment = "bottom_left",
};

conky.text = [[
${font sans-serif:bold:size=9}Open new terminal ${font sans-serif:normal:size=9} mod+Return
${font sans-serif:bold:size=9}Search application ${font sans-serif:normal:size=9} mod+d
${font sans-serif:bold:size=9}Toggle Mute ${font sans-serif:normal:size=9} mod+m
${font sans-serif:bold:size=9}Increase Volume ${font sans-serif:normal:size=9} mod+plus
${font sans-serif:bold:size=9}Decrease Volume ${font sans-serif:normal:size=9} mod+minus
${font sans-serif:bold:size=9}Increase Brightness ${font sans-serif:normal:size=9} mod+Shift+plus
${font sans-serif:bold:size=9}Decrease Brightness ${font sans-serif:normal:size=9} mod+Shift+minus
${font sans-serif:bold:size=9}Code ${font sans-serif:normal:size=9} mod+c
${font sans-serif:bold:size=9}Music Player ${font sans-serif:normal:size=9} mod+p
${font sans-serif:bold:size=9}Browse files ${font sans-serif:normal:size=9} mod+n
${font sans-serif:bold:size=9}Kill focused ${font sans-serif:normal:size=9} mod+Shift+q
${font sans-serif:bold:size=9}Switch to workspace 1-9 ${font sans-serif:normal:size=9} mod+1-9
${font sans-serif:bold:size=9}Send to workspace 1-9 ${font sans-serif:normal:size=9} mod+Shift+1-9
${font sans-serif:bold:size=9}Toggle fullscreen ${font sans-serif:normal:size=9} mod+f
${font sans-serif:bold:size=9}Toggle floating ${font sans-serif:normal:size=9} mod+Shift+space
${font sans-serif:bold:size=9}Exit ${font sans-serif:normal:size=9} mod+0

${font sans-serif:bold:size=9}Default mod ${font sans-serif:normal:size=9} <Super>
]];


'

}


generate_conky_helper $1 | tee ~/.config/conky/helper.conf
