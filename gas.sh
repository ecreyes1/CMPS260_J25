
#!/bin/bash
declare  -A  COST
GAS_TYPE=""
COST[Regular]=5.02
COST[Midgrade]=5.22
COST[Premium]=5.42
COST[Diesel]=6.03
echo "-------------Welcome to gas for taxes-------------"
echo "|      Gas Type       |         Price           | "
echo "|      Regular        |         5.02           | " 
echo "|      Midgrade       |         5.22           | "  
echo "|      Premium        |         5.42           | "
echo "|      Diesel         |         6.03           | "
echo "--------------------------------------------------"
echo -n "Choose Gas type: "
read GAS_TYPE
if [[ -z "${COST[$GAS_TYPE]}" ]]; then
echo "invalid gas type"
exit 1
fi
echo -n "How many gallons: "
read gallons

total=$(echo "${COST[$GAS_TYPE]} * $gallons" | bc)
printf "your total is \$%.2f\n" "$total"
 echo  -n "Enter payment method"
read payment
printf "Great ! you have paid the balance of \$%.2f using your %s.\n" "$total" "$payment"
echo "Thanks for filling up at Gas 4 taxes, a place to get broke"
