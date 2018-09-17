#env
if [ "$FN_PATH" = "/upper" ]; then
   tr [:lower:] [:upper:]
fi
if [ "$FN_PATH" = "/lower" ]; then
   tr  [:upper:] [:lower:]
fi
