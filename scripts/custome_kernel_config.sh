#!/bin/bash

source .current_config.mk
KCFG=kernel/arch/arm64/configs/$(awk '{print $1}' <<< "$TARGET_KERNEL_CONFIG")
if [ -f $KCFG ]; then
    if grep -q '^CONFIG_SPI=' $KCFG; then
        sed -i 's@^CONFIG_SPI=.*@CONFIG_SPI=y@' $KCFG
    else
        echo 'CONFIG_SPI=y' >> $KCFG
    fi
else
    echo "Error: File not found: $KCFG"
    exit 1	
fi
