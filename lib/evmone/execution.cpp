// evmone: Fast Ethereum Virtual Machine implementation
// Copyright 2019 Pawel Bylica.
// Licensed under the Apache License, Version 2.0.

#include "execution.hpp"
#include "analysis.hpp"
#include <memory>
#include <iostream>
#include <sstream>

namespace evmone
{
evmc_result execute(evmc_vm* /*unused*/, const evmc_host_interface* host, evmc_host_context* ctx,
    evmc_revision rev, const evmc_message* msg, const uint8_t* code, size_t code_size)
{
    auto analysis = analyze(rev, code, code_size, ctx);

    auto state = std::make_unique<execution_state>();
    state->analysis = &analysis;
    state->msg = msg;
    state->code = code;
    state->code_size = code_size;
    state->host = evmc::HostContext{*host, ctx};
    state->gas_left = msg->gas;
    state->rev = rev;

    const auto* instr = &state->analysis->instrs[0];
    std::cout<<std::endl<<"***** start execution"<<std::endl;
    std::stringstream ss;
    while (instr != nullptr)
    {
        instr = instr->fn(instr, *state);
        ss<<" "<<state->gas_left;
        std::cout<<state->gas_left<<std::endl;
    }
    std::cout<<std::endl<<ss.str()<<std::endl;
    std::cout<<std::endl<<"***** end execution"<<std::endl;
    const auto gas_left =
        (state->status == EVMC_SUCCESS || state->status == EVMC_REVERT) ? state->gas_left : 0;

    return evmc::make_result(
        state->status, gas_left, &state->memory[state->output_offset], state->output_size);
}
}  // namespace evmone
