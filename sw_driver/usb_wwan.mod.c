#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xd31aec96, "module_layout" },
	{ 0x52d1fb52, "kmalloc_caches" },
	{ 0x1fdc7df2, "_mcount" },
	{ 0x12a4e128, "__arch_copy_from_user" },
	{ 0x85742949, "usb_get_from_anchor" },
	{ 0x759ea8c3, "usb_kill_urb" },
	{ 0xf6987f42, "param_ops_bool" },
	{ 0xa5afb83e, "usb_autopm_get_interface" },
	{ 0x409bcb62, "mutex_unlock" },
	{ 0x4ecbb36d, "usb_unlink_urb" },
	{ 0x15ba50a6, "jiffies" },
	{ 0xd9a5ea54, "__init_waitqueue_head" },
	{ 0x4b0a3f52, "gic_nonsecure_priorities" },
	{ 0xd35cce70, "_raw_spin_unlock_irqrestore" },
	{ 0xc5850110, "printk" },
	{ 0x3127bd06, "usb_autopm_put_interface_async" },
	{ 0xec3f4348, "usb_control_msg" },
	{ 0x4b750f53, "_raw_spin_unlock_irq" },
	{ 0x73c29162, "tty_insert_flip_string_fixed_flag" },
	{ 0x2ab7989d, "mutex_lock" },
	{ 0xc6cbbc89, "capable" },
	{ 0x1ca7fb0d, "usb_submit_urb" },
	{ 0xb3dafda0, "usb_autopm_get_interface_async" },
	{ 0x6a5cb5ee, "__get_free_pages" },
	{ 0x6cbbfc54, "__arch_copy_to_user" },
	{ 0x86332725, "__stack_chk_fail" },
	{ 0x8427cc7b, "_raw_spin_lock_irq" },
	{ 0x49f2fa43, "cpu_hwcaps" },
	{ 0xf424b0fe, "cpu_hwcap_keys" },
	{ 0xac67b9cc, "dev_driver_string" },
	{ 0x9ac23f86, "kmem_cache_alloc_trace" },
	{ 0x34db050b, "_raw_spin_lock_irqsave" },
	{ 0x4302d0eb, "free_pages" },
	{ 0xd35550fe, "usb_autopm_get_interface_no_resume" },
	{ 0x409873e3, "tty_termios_baud_rate" },
	{ 0x37a0cba, "kfree" },
	{ 0x4829a47e, "memcpy" },
	{ 0x56c80a72, "tty_flip_buffer_push" },
	{ 0x6ebe366f, "ktime_get_mono_fast_ns" },
	{ 0x74a29fd0, "usb_serial_port_softint" },
	{ 0x14b89635, "arm64_const_caps_ready" },
	{ 0xcb855872, "usb_free_urb" },
	{ 0x4b15198, "usb_autopm_put_interface" },
	{ 0x826f1e2d, "usb_anchor_urb" },
	{ 0x655fc02e, "usb_alloc_urb" },
};

MODULE_INFO(depends, "usbserial");


MODULE_INFO(srcversion, "19011C4EF5538CAFCFE593F");
