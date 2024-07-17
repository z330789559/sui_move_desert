#[allow(unused_use)]
#[test_only]
module nft_first::nft_first_test {
    use sui::tx_context::{Self, TxContext};
    use sui::test_scenario::{Self};
    use nft_first::sword_nft::{Self,Sword,sword_transfer,magic,strength, Forge};

    #[test]
    public fun test_sword_create(){
        let admin = @0x0;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        test_scenario::next_tx(scenario, admin);
        {
            sword_nft::init_for_testing(test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, admin);
        {
            let  _forge =test_scenario::take_from_sender<Forge>(scenario);
            sword_nft::sword_create(&mut _forge,42, 7, initial_owner, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, _forge);
        };
        test_scenario::next_tx(scenario, initial_owner);
        {
            let sword = test_scenario::take_from_sender<Sword>(scenario);
            sword_transfer(sword, final_owner, test_scenario::ctx(scenario));

        };
        test_scenario::next_tx(scenario, final_owner);
        {
            let sword = test_scenario::take_from_sender<Sword>(scenario);
            assert!(magic(&sword) == 42 && strength(&sword) == 7, 1);
            // sword_transfer(sword, admin, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, sword);


        };
        test_scenario::end(scenario_val);

    }
}
