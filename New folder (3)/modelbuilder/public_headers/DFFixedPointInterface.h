// Copyright  2009 - 2017 Keysight Technologies, Inc  
//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//-----------------------------------------------------------------------------------

#pragma once

#include "eresult.h"
#include "FixedPoint.h"

namespace SystemVueModelBuilder
{
	class DFFixedPointInterface
	{
	public:
		virtual ERESULT SetOutputFixedPointParameters()
		{
			return E_NOTIMPL_;
		}
	};
}
