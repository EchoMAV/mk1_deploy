cmd_/home/echopilot/mk1_deploy/sw_driver/qmi_wwan.ko := ld -r  -m elf_x86_64 -z noexecstack   --build-id=sha1  -T scripts/module.lds -o /home/echopilot/mk1_deploy/sw_driver/qmi_wwan.ko /home/echopilot/mk1_deploy/sw_driver/qmi_wwan.o /home/echopilot/mk1_deploy/sw_driver/qmi_wwan.mod.o;  true