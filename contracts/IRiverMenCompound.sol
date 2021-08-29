// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


interface IRiverMenCompound {

    /* ================ TRANSACTIONS ================ */
    function compound(uint256[] memory tokenIds) external;
}
