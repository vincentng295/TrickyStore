DEBUG=@DEBUG@

MODDIR=${0%/*}

cd $MODDIR

(
while [ true ]; do
  ./daemon
  if [ $? -ne 0 ]; then
    exit 1
  fi
done
) &

check_resetprop(){
    local VALUE="$(resetprop -v "$1")"
    [ ! -z "$VALUE" ] && [ "$VALUE" != "$2" ] && resetprop -v -n "$1" "$2"
}

maybe_resetprop(){
    local VALUE="$(resetprop -v "$1")"
    [ ! -z "$VALUE" ] && echo "$VALUE" | grep -q "$2" && resetprop -v -n "$1" "$3"
}

replace_value_resetprop(){
    local VALUE="$(resetprop -v "$1")"
    [ -z "$VALUE" ] && return
    local VALUE_NEW="$(echo -n "$VALUE" | sed "s|${2}|${3}|g")"
    [ "$VALUE" == "$VALUE_NEW" ] || resetprop -v -n "$1" "$VALUE_NEW"
}

check_resetprop ro.boot.vbmeta.device_state locked
check_resetprop ro.boot.verifiedbootstate green
check_resetprop ro.boot.flash.locked 1
check_resetprop ro.boot.veritymode enforcing
check_resetprop ro.boot.warranty_bit 0
check_resetprop ro.warranty_bit 0
check_resetprop ro.debuggable 0
check_resetprop ro.secure 1
check_resetprop ro.build.type user
check_resetprop ro.build.tags release-keys
check_resetprop ro.vendor.boot.warranty_bit 0
check_resetprop ro.vendor.warranty_bit 0
check_resetprop vendor.boot.vbmeta.device_state locked
check_resetprop vendor.boot.verifiedbootstate green
check_resetprop sys.oem_unlock_allowed 0
check_resetprop init.svc.flash_recovery stopped

maybe_resetprop ro.bootmode recovery unknown
maybe_resetprop ro.boot.mode recovery unknown
maybe_resetprop vendor.bootmode recovery unknown
maybe_resetprop vendor.boot.mode recovery unknown
maybe_resetprop ro.boot.hwc CN GLOBAL
maybe_resetprop ro.boot.hwcountry China GLOBAL
selinux="$(resetprop ro.build.selinux)"
[ -z "$selinux" ] || resetprop --delete ro.build.selinux

for prefix in system vendor system_ext product oem odm vendor_dlkm odm_dlkm; do
    check_resetprop ro.${prefix}.build.type user
    check_resetprop ro.${prefix}.build.tags release-keys
done

if [[ "$(resetprop -v ro.product.first_api_level)" -ge 33 ]]; then
    resetprop -v -n ro.product.first_api_level 32
fi
