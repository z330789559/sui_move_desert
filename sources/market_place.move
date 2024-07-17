
module nft_first::market_place{
    use sui::object::{Self, UID,ID,uid_as_inner};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event::emit;
    use sui::table;
    use std::string::{String};
    use sui::coin;
    use sui::table::Table;
    use sui::dynamic_object_field as ofield;
    use sui::coin::Coin;
    use sui::transfer::transfer;
    use sui::bag::{Self,Bag};

    const ENotOwner:u64=1;
    const EAmountIncorrect:u64=2;

    struct Marketplace<phantom COIN> has key {
        id: UID,
        items: Bag,
        payments: Table<address, Coin<COIN>>
    }

    struct Listing has key, store {
        id: UID,
        ask: u64,
        owner: address
    }

    #[allow(unused_function)]
    // create new shared marketplace
    public entry fun create<COIN>(ctx: &mut TxContext) {
        let id = object::new(ctx);
        let items = bag::new(ctx);
        let payments = table::new<address, Coin<COIN>>(ctx);
        transfer::share_object(Marketplace<COIN> {
            id,
            items,
            payments
        })
    }

    // listing an item at the marketplace
    public entry fun list<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item: T,
        ask: u64,
        ctx: &mut TxContext
    ) {
        let item_id = object::id(&item);
        let listing = Listing {
            id: object::new(ctx),
            ask: ask,
            owner: tx_context::sender(ctx),
        };

        ofield::add(&mut listing.id, true, item);
        bag::add(&mut marketplace.items, item_id, listing)
    }

    // internal function to remove listing and get item back, only owner can do
    fun delist<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        ctx: &TxContext
    ): T {
        let Listing { id, owner, ask: _ } = bag::remove<ID,Listing>(&mut marketplace.items, item_id);

        assert!(tx_context::sender(ctx) == owner, ENotOwner);

        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    // call delist function and transfer item to sender
    public entry fun delist_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        ctx: &mut TxContext
    ) {
        let item = delist<T, COIN>(marketplace, item_id, ctx);
        transfer::public_transfer(item, tx_context::sender(ctx));
    }

    // internal function to purchase item using known Listing
    // payment is done in Coin<C>
    // if conditions are correct, owner of item gets payment and buyer receives item
    fun buy<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        paid: Coin<COIN>,
    ): T {
        let Listing { id, ask, owner } = bag::remove<ID,Listing>(&mut marketplace.items, item_id);

        assert!(ask == coin::value(&paid), EAmountIncorrect);

        // check if theres alr a Coin hanging, if yes, merge paid with it
        // otherwise, attach paid to Marketplace under owner's address
        if (table::contains<address, Coin<COIN>>(&marketplace.payments, owner)) {
            coin::join(
                table::borrow_mut<address, Coin<COIN>>(&mut marketplace.payments, owner),
                paid
            )
        } else {
            table::add(&mut marketplace.payments, owner, paid)
        };

        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    // call buy function and transfer item to sender
    public entry fun buy_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        paid: Coin<COIN>,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            buy<T, COIN>(marketplace, item_id, paid),
            tx_context::sender(ctx)
        )
    }

    // internal function to take profits from selling items on marketplace
    fun take_profits<COIN>(
        marketplace: &mut Marketplace<COIN>,
        ctx: &TxContext
    ): Coin<COIN> {
        table::remove<address, Coin<COIN>>(&mut marketplace.payments, tx_context::sender(ctx))
    }

    // call take_profits function and transfers Coin object to sender
    public entry fun take_profits_and_keep<COIN>(
        marketplace: &mut Marketplace<COIN>,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(take_profits(marketplace, ctx), tx_context::sender(ctx))
    }
}