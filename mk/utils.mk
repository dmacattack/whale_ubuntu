define msg
@printf "\033[7m >>> %s \033[0m\n" "$(strip $(1))"
endef

define get_partition_start
$(shell $(OBJDIR)/bin/gpt-manipulator $(1) --get-first-lba $(2))
endef

define chroot_cmd
chroot $(ROOTDIR)
endef

define apt_get
env DEBIAN_FRONTEND=noninteractive LANG=C apt-get \
	-o Dpkg::Options::=--force-confdef \
	-o Dpkg::Options::=--force-confnew \
	-o Dpkg::Options::=--force-overwrite \
	-y -q install --no-install-recommends $(strip $(1))
endef
