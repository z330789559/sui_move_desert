#[allow(unused_use)]


module nft_first::sword_nft {



    use sui::object::{Self, UID,ID,uid_as_inner};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event::emit;
    use sui::table;
    use std::string::{String};
    use sui::transfer::transfer;
    use sui::bag;
    use sui::kiosk;

    const Forge_Create: u8 = 1;

    const Sword_Create: u8 = 2;

    struct Outcome has copy, drop {
        game_id: ID,
        status: u8
    }
    struct SwordCreate has copy, drop {
        status: u8,
        sword_id: ID
    }
    struct SwordTransfer has copy, drop {
            sword_id: ID,
            recipient: address
    }


    struct Sword has key, store {
        id: UID,
        magic: u64,
        strength: u64,
    }

    struct Forge has key, store {
        id: UID,
        swords_created: u64,
    }
    struct  Name has copy, store,drop{
        name: String,
    }

   fun init(ctx: &mut TxContext) {
    let forge = Forge {
      id:  object::new(ctx),
      swords_created: 0,
    };
      let id=*uid_as_inner(&forge.id);
      transfer::transfer(forge,tx_context::sender(ctx));
      emit(Outcome{
            game_id: id,
            status: Forge_Create
      })
  }

    public entry  fun sword_create( forge: &mut Forge,magic: u64, strength: u64, recipient: address, ctx: &mut TxContext){
        use sui::transfer;

        // create a sword
        let sword = Sword {
            id: object::new(ctx),
            magic: magic,
            strength: strength,
        };
        forge.swords_created = forge.swords_created + 1;
        emit(SwordCreate{
            status: Sword_Create,
            sword_id: object::id(&sword)

        });
        // transfer the sword
        transfer::transfer(sword, recipient);


    }

    public entry fun sword_transfer(sword: Sword, recipient: address, _ctx: &mut TxContext) {
        use sui::transfer;
        // transfer the sword
        let id = *uid_as_inner(&sword.id);
        transfer::transfer(sword, recipient);
        emit(SwordTransfer{sword_id:id, recipient});
    }
    public fun magic(self: &Sword): u64 {
        self.magic
    }

    public fun strength(self: &Sword): u64 {
        self.strength
    }

    public fun swords_created(self: &Forge): u64 {
        self.swords_created
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx)
    }

}
