#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace;

LOGMSG() {
	echo "I:$@" >> /tmp/recovery.log
}

quit() {
	LOGMSG "$@ is loaded";
}

load_drivers() {
	local path1=/lib/modules;
	local path2=/vendor/lib/modules/1.1;
        local modules="adsp_loader_dlkm aw8697-haptic gpr_dlkm nt38771_touch nxp-nci panel_event_notifier pdr_interface \
                       q6_notifier_dlkm q6_pdr_dlkm qcom_glink qcom_glink_smem qcom_pil_info qcom_q6v5 qcom_q6v5_pas qcom_ramdump \
                       qcom_smd qcom_sysmon qmi_helpers rproc_qcom_common si_haptic snd_event_dlkm spf_core_dlkm xiaomi_touch"

	# loop through the modules
	for i in $modules; do
		# check whether the module is already loaded
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# try to load the module
		insmod "$path1/$i.ko"
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		insmod "$path2/$i.ko"
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# module failed to load from all paths
		LOGMSG "$i failed to load"
	done
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"
load_drivers;
LOGMSG "---$SCRIPT_NAME end---"
exit 0
