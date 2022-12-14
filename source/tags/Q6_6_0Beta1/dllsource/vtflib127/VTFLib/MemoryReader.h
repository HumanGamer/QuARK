/*
 * VTFLib
 * Copyright (C) 2005-2008 Neil Jedrzejewski & Ryan Gregg

 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later
 * version.
 */

#ifndef MEMORYREADER_H
#define MEMORYREADER_H

#include "stdafx.h"
#include "Reader.h"

namespace VTFLib
{
	namespace IO
	{
		namespace Readers
		{
			class CMemoryReader : public IReader
			{
			private:
				vlBool bOpened;

				const vlVoid *vData;
				vlUInt uiBufferSize;

				vlUInt uiPointer;

			public:
				CMemoryReader(const vlVoid *vData, vlUInt uiBufferSize);
				~CMemoryReader();

			public:
				virtual vlBool Opened() const;

				virtual vlBool Open();
				virtual vlVoid Close();

				virtual vlUInt GetStreamSize() const;
				virtual vlUInt GetStreamPointer() const;

				virtual vlUInt Seek(vlLong lOffset, vlUInt uiMode);

				virtual vlBool Read(vlChar &cChar);
				virtual vlUInt Read(vlVoid *vData, vlUInt uiBytes);
			};
		}
	}
}

#endif