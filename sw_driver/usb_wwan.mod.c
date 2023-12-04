#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

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
	{ 0x4cf819e6, "module_layout" },
	{ 0x696f0c3, "kmalloc_caches" },
	{ 0x54b1fac6, "__ubsan_handle_load_invalid_value" },
	{ 0x1cd6d5ed, "usb_get_from_anchor" },
	{ 0x73dc96bd, "usb_kill_urb" },
	{ 0x83253110, "param_ops_bool" },
	{ 0xc9c51f39, "usb_autopm_get_interface" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0xca666cb7, "usb_unlink_urb" },
	{ 0x33a21a09, "pv_ops" },
	{ 0x15ba50a6, "jiffies" },
	{ 0xd9a5ea54, "__init_waitqueue_head" },
	{ 0x6b10bee1, "_copy_to_user" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0xd35cce70, "_raw_spin_unlock_irqrestore" },
	{ 0x467b419c, "usb_autopm_put_interface_async" },
	{ 0xcc7ef1da, "usb_control_msg" },
	{ 0x7b0aeebd, "tty_insert_flip_string_fixed_flag" },
	{ 0x4dfa8d4b, "mutex_lock" },
	{ 0x87a21cb3, "__ubsan_handle_out_of_bounds" },
	{ 0xc6cbbc89, "capable" },
	{ 0xbd70750d, "usb_submit_urb" },
	{ 0xe034150c, "usb_autopm_get_interface_async" },
	{ 0x6a5cb5ee, "__get_free_pages" },
	{ 0xd0da656b, "__stack_chk_fail" },
	{ 0x8427cc7b, "_raw_spin_lock_irq" },
	{ 0x92997ed8, "_printk" },
	{ 0xb06a469c, "dev_driver_string" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x4f00afd3, "kmem_cache_alloc_trace" },
	{ 0x34db050b, "_raw_spin_lock_irqsave" },
	{ 0x4302d0eb, "free_pages" },
	{ 0x1f9ee705, "usb_autopm_get_interface_no_resume" },
	{ 0x409873e3, "tty_termios_baud_rate" },
	{ 0x37a0cba, "kfree" },
	{ 0x42dc216a, "tty_flip_buffer_push" },
	{ 0x6ebe366f, "ktime_get_mono_fast_ns" },
	{ 0xff99d0fb, "usb_serial_port_softint" },
	{ 0x13c49cc2, "_copy_from_user" },
	{ 0x88bce085, "usb_free_urb" },
	{ 0x7680ff31, "usb_autopm_put_interface" },
	{ 0x29169978, "usb_anchor_urb" },
	{ 0x1f861c5f, "usb_alloc_urb" },
};

MODULE_INFO(depends, "usbserial");


MODULE_INFO(srcversion, "19011C4EF5538CAFCFE593F");
