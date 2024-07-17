module nft_first::token_while_list {

    use std::option;
    use std::vector;
    use sui::address;
    use sui::coin::TreasuryCap;
    use sui::event::emit;
    use sui::object::{Self,UID};
    use sui::transfer;
    use sui::tx_context::{Self,TxContext};
    use sui::coin;
    use sui::dynamic_object_field as ofield;
         struct TOKEN_WHILE_LIST has drop {

          }

          const MissWhileList:u64=1;

            struct  WhileListCap has key {
                id: UID,
            }

            struct WhileList has key,store {
                id: UID,
                while_list: vector<address>,
            }

        struct MintEvent  has drop,copy{
            recipient: address,
            amount: u64,
        }


    fun init(witness:TOKEN_WHILE_LIST,ctx :&mut TxContext){

        let (treasury, metadata) = coin::create_currency(witness, 6, b"FDCOIN", b"FDCOIN", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx));
        let  wl = WhileList{
            id: object::new(ctx),
            while_list: vector::empty<address>(),
        };
        let whileListCap = WhileListCap{
            id: object::new(ctx)
        };
        transfer::transfer(whileListCap, tx_context::sender(ctx));
        transfer::public_share_object(wl)
    }

    public  entry fun  addWhileList(_:&WhileListCap, whileList:&mut WhileList,while_list:vector<address>){
        vector::append(&mut whileList.while_list,while_list);
        // ofield::add(&mut whileList.id, true, item);
    }

    public  entry fun  mint(whileList:&WhileList, cap: &mut TreasuryCap<TOKEN_WHILE_LIST>,recipient:address ,ctx :&mut TxContext){
      let (resut,_)=  vector::index_of<address>(&whileList.while_list,&recipient);
        assert!(resut,MissWhileList );
       let balance= coin::mint(cap,100, ctx,);
         transfer::public_transfer(balance,recipient);
        emit(MintEvent{
            recipient: recipient,
            amount:100
        })
    }


}
