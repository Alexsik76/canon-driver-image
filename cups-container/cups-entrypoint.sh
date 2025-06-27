#!/bin/bash

# Start the CUPS daemon in the background
echo "Starting CUPS daemon..."
/usr/sbin/cupsd -f & # Run cupsd in the background
CUPSD_PID=$! # Store its PID

# Wait a moment for CUPS to initialize
echo "Waiting for CUPS to initialize..."
sleep 5 # Adjust this if CUPS needs more time to start up

# Register the printer using lpadmin
echo "Registering printer LBP6000 with CUPS..."
lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://ccpd:59687 -E
if [ $? -eq 0 ]; then
    echo "Printer LBP6000 registered successfully."
else
    echo "Failed to register printer LBP6000. Check logs."
fi

# Keep the CUPS daemon running
wait $CUPSD_PID