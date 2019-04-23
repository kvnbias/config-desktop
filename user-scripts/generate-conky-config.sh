
#!/bin/bash
# ~/.config/conky/generate-conky-config.sh '#ffffff'

generate_conky_config() {
    echo '
-- vim: ts=4 sw=4 noet ai cindent syntax=lua
--[[
/etc/conky/conky.conf
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
    gap_y = 48,
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
    alignment = "top_right",
};

conky.text = [[
${font sans-serif:bold:size=18}${alignc}${time %H:%M}${font}
${voffset 4}${alignc}${time %A %B %d, %Y}
${font}${voffset -4}
${font sans-serif:bold:size=10}SYSTEM ${hr 2}
${font sans-serif:normal:size=8}$sysname $kernel $alignr $machine
Host:$alignr$nodename
Uptime:$alignr$uptime
File System: $alignr${fs_type}
Processes: $alignr ${execi 1000 ps aux | wc -l}

${font sans-serif:bold:size=10}COMPONENTS ${hr 2}'

cpuinfo=
cpucount=$(nproc --all)

for (( c=1; c<=$cpucount; c++ ))
do
    cpuinfo+='${font sans-serif:normal:size=8}CPU'$c' $alignr ${cpu cpu'$c$'}%\n'
    cpuinfo+='${cpubar cpu'$c$'}\n'
done

echo -n "$cpuinfo"

echo '${font sans-serif:normal:size=8}RAM $alignc $mem / $memmax $alignr $memperc%
$membar
SWAP $alignc ${swap} / ${swapmax} $alignr ${swapperc}%
${swapbar}
${font sans-serif:normal:size=8}ROOT / $alignc ${fs_used /} / ${fs_size /} $alignr ${fs_used_perc /}%
${fs_bar /}
${font sans-serif:normal:size=8}HOME /home $alignc ${fs_used /home} / ${fs_size /home} $alignr ${fs_used_perc /home}%
${fs_bar /home}
'

ethernet=$(nmcli device | grep ethernet | grep -Eo '^[^ ]+')
echo "\${font sans-serif:bold:size=10}LAN \${hr 2}
\${font sans-serif:normal:size=8}Down: \${downspeed $ethernet}  \${alignr}Up: \${upspeed $ethernet}"

wifi=$(nmcli device | grep wifi | grep -Eo '^[^ ]+')
echo "\${font sans-serif:bold:size=10}WIFI \${hr 2}
\${font sans-serif:normal:size=8}Down: \${downspeed $wifi}  \${alignr}Up: \${upspeed $wifi}"

echo '${font sans-serif:bold:size=10}TOP PROCESSES ${hr 2}
${font sans-serif:normal:size=8}Name $alignr PID   CPU%   MEM%${font sans-serif:normal:size=8}
${top name 1} $alignr ${top pid 1} ${top cpu 1}% ${top mem 1}%
${top name 2} $alignr ${top pid 2} ${top cpu 2}% ${top mem 2}%
${top name 3} $alignr ${top pid 3} ${top cpu 3}% ${top mem 3}%
${top name 4} $alignr ${top pid 4} ${top cpu 4}% ${top mem 4}%
${top name 5} $alignr ${top pid 5} ${top cpu 5}% ${top mem 5}%
${top name 6} $alignr ${top pid 6} ${top cpu 6}% ${top mem 6}%
${top name 7} $alignr ${top pid 7} ${top cpu 7}% ${top mem 7}%
${top name 8} $alignr ${top pid 8} ${top cpu 8}% ${top mem 8}%
${top name 9} $alignr ${top pid 9} ${top cpu 9}% ${top mem 9}%
${top name 10} $alignr ${top pid 10} ${top cpu 10}% ${top mem 10}%
]];
'

}


generate_conky_config $1 | tee ~/.config/conky/conky.conf
