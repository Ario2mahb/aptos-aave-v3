#[test_only]
module aave_config::user_tests {
    use aave_config::user::{
        set_using_as_collateral,
        is_borrowing_any,
        is_using_as_collateral_or_borrowing,
        set_borrowing,
        is_borrowing,
        is_borrowing_one,
        is_using_as_collateral,
        is_using_as_collateral_any,
        is_using_as_collateral_one,
        get_rebalance_up_liquidity_rate_threshold,
        get_minimum_health_factor_liquidation_threshold,
        get_health_factor_liquidation_threshold,
        get_isolated_collateral_supplier_role,
        test_init_module,
        is_empty,
        get_user_config_map,
        get_rebalance_up_liquidity_rate_threshold_for_testing,
        get_minimum_health_factor_liquidation_threshold_for_testing,
        get_health_factor_liquidation_threshold_for_testing,
        get_isolated_collateral_supplier_role_for_testing,
    };
    use aave_config::helper::{Self};

    const TEST_SUCCESS: u64 = 1;
    const TEST_FAILED: u64 = 2;

    #[test(admin = @aave_config)]
    fun test_user_config(admin: &signer) {
        test_init_module(admin);
        assert!(get_rebalance_up_liquidity_rate_threshold() == get_rebalance_up_liquidity_rate_threshold_for_testing(),
            TEST_SUCCESS);
        assert!(get_minimum_health_factor_liquidation_threshold() == get_minimum_health_factor_liquidation_threshold_for_testing(),
            TEST_SUCCESS);
        assert!(get_health_factor_liquidation_threshold() == get_health_factor_liquidation_threshold_for_testing(),
            TEST_SUCCESS);
        assert!(get_isolated_collateral_supplier_role() == get_isolated_collateral_supplier_role_for_testing(),
            TEST_SUCCESS);
        // test default values
        let user_config_map = get_user_config_map();
        assert!(is_empty(&user_config_map), TEST_SUCCESS);
        assert!(!is_borrowing_any(&user_config_map), TEST_SUCCESS);
        assert!(!is_using_as_collateral_any(&user_config_map), TEST_SUCCESS);
        let user_config_map = get_user_config_map();
        // test borrowing
        let reserve_index: u256 = 1;
        set_borrowing(&mut user_config_map, reserve_index, true);
        assert!(is_borrowing(&mut user_config_map, reserve_index), TEST_SUCCESS);
        assert!(is_borrowing_any(&mut user_config_map), TEST_SUCCESS);
        assert!(is_borrowing_one(&mut user_config_map), TEST_SUCCESS);
        assert!(is_using_as_collateral_or_borrowing(&mut user_config_map, reserve_index),
            TEST_SUCCESS);
        // test collateral
        set_using_as_collateral(&mut user_config_map, reserve_index, true);
        assert!(is_using_as_collateral(&user_config_map, reserve_index), TEST_SUCCESS);
        assert!(is_using_as_collateral_any(&user_config_map), TEST_SUCCESS);
        assert!(is_using_as_collateral_one(&user_config_map), TEST_SUCCESS);
        assert!(is_using_as_collateral_or_borrowing(&user_config_map, reserve_index),
            TEST_SUCCESS);
    }

    #[test]
    fun test_bit_shifts() {
        let reserve_index: u256 = 127;
        let bit: u256 = 1 << ((reserve_index << 1) as u8);
        let data: u256 = 100000;
        data = data & helper::bitwise_negation(bit);
        assert!(data == 100000, 1);
    }

    #[test]
    #[expected_failure(arithmetic_error, location = Self)]
    fun test_bit_shifts_arithmetic_error() {
        let reserve_index: u256 = 128;
        let bit: u256 = 1 << ((reserve_index << 1) as u8);
        let data: u256 = 100000;
        data = data & helper::bitwise_negation(bit);
        assert!(data == 100000, TEST_FAILED);
    }
}
