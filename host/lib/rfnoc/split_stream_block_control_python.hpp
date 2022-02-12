//
// Copyright 2020 Ettus Research, a National Instruments Brand
//
// SPDX-License-Identifier: GPL-3.0-or-later
//

#pragma once

#include "block_controller_factory_python.hpp"
#include <uhd/rfnoc/split_stream_block_control.hpp>

using namespace uhd::rfnoc;

void export_split_stream_block_control(py::module& m)
{
    py::class_<split_stream_block_control, noc_block_base, split_stream_block_control::sptr>(
        m, "split_stream_block_control")
        .def(py::init(&block_controller_factory<split_stream_block_control>::make_from));
}