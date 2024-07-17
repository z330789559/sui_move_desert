
```shell


#call fun sword_create
sui client call --package $PACKAGE --module my_module --function sword_create  --args 0x9793145a61038e1a954fc7331f5109eec3b0582f0f245365bd3e7df9b22e089a  40 7 0x485e88852f4e94ab25ddd2f16c17c33a50aaac09023db20e0ec3d7d9613dc084 --gas-budget 3000000

#call fun sword_transfer
sui client call --package $PACKAGE --module my_module --function sword_transfer  --args 0x0736be0a4f290b899f6f8cbf611f9be91b16d5df88227b7c439ed629ce546157  0x108f592149039402f7067387c62b581df55d9bc38b47b730abd95b3d59ece7e3 --gas-budget 3000000
```

