
dir=$1

if [ -z "$dir" ]; then
  dir="$HOME"
fi

ls -a $dir | grep -v ^.$ | grep -v ^..$ | while read i; do
  sudo du -sh "$dir/$i"
done

