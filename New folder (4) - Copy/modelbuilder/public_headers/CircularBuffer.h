// Copyright  2009 - 2017 Keysight Technologies, Inc 
#pragma once

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//-----------------------------------------------------------------------------------

#include "CommonBase.h"
#include <algorithm>
#include <crtdbg.h>
#include <complex>

namespace SystemVueModelBuilder
{

	/// The CircularBuffer class enables your models to use circular buffers to implement your DFPorts.
	/// <remarks>The CircularBuffer class is an abstract base class.</remarks>
	class MODELBUILDER_API CircularBufferBase
	{
	public:

		/// Constructor
		CircularBufferBase()
		{
			m_pBuffer = 0;
			m_iCurrent = m_iSize = 0;
			m_iHistoryDepth = m_iRate = 1;
			m_bContiguousBuffer = false;
		}

		/// Virtual Destructor
		virtual ~CircularBufferBase() {}

		/// The SetBuffer method is called by SystemVue to setup the circular buffers for DFPorts.  If you want to create your own circular buffer for use inside of your model, you will need to call this method.  Otherwise, you should not call this method.
		/// <param name="pBuffer">A pointer to circular memory buffer.</param>
		/// <param name="iNumberItems">The number of items that the circular buffer can hold.</param>
		/// <param name="iAdvanceRate">The amount that the buffer index is incremented when the Advance method is invoked.</param>
		/// <param name="iStartLocation">The initial buffer location.</param>
		/// <remarks>The CircularBuffer class will not deallocate this memory. If the <c>GetReadPtr()</c>, <c>GetWritePtr()</c> and <c>Write()</c> methods are going to be called, the actual buffer size may have to be larger than iNumberItems parameter.</remarks>		
		void SetBuffer(void* pBuffer, size_t iNumberItems, size_t iAdvanceRate = 1, size_t iStartLocation = 0)
		{
			// Either the buffer should be being set to empty or the buffer parameters must be logical for indexing
			_ASSERT( (iStartLocation == 0 && iNumberItems ==0 && pBuffer == 0) || 
				( iStartLocation < iNumberItems && iAdvanceRate <= iNumberItems) );

			m_pBuffer = pBuffer;
			m_iSize = iNumberItems;
			m_iRate = iAdvanceRate;
			m_iCurrent = iStartLocation;
		}

		/// The SetRate method sets the multirate property on the CircularBuffer.  This should only be called in the Setup method.
		/// <param name="iRate">The multirate value (i.e. number produced / consumed each invocation of your model).</param>
		void SetRate( size_t iRate)
		{
			m_iRate = iRate;
			if(m_iHistoryDepth < m_iRate)
			{
				m_iHistoryDepth = m_iRate;
			}
		}

		/// The GetRate method gets the multirate property on the CircularBuffer. 
		/// <param name="iRate">The multirate value (i.e. number produced / consumed each invocation of your model).</param>
		size_t GetRate() const
		{
			return m_iRate;
		}

		/// The SetHistoryDepth method sets the total number of samples that can be indexed by CircularBuffer. 
		/// The index [0] will point to the oldest sample in the history. By default the HistoryDepth is equal to
		/// multi-rate value. This method should only be called in the Setup method.
		/// <param name="iHistoryDepth">The total number of samples that can be indexed by CircularBuffer.</param> 
		void SetHistoryDepth(size_t iHistoryDepth)
		{
			// Tap delay line size must be greater than multirate value
			_ASSERT(iHistoryDepth > m_iRate); 

			m_iHistoryDepth = iHistoryDepth;
		}

		/// The total number of samples that can be indexed by CircularBuffer.
		/// The index [0] will point to the oldest sample in the history.
		size_t GetHistoryDepth()
		{
			return m_iHistoryDepth;
		}



		/// The Copy method copies iNumberItems from pSource to pDestination.
		/// <param name="pSource">Pointer to thebuffer to copy data from. </param>
		/// <param name="pDestination">Pointer to the buffer to copy data to.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		virtual void Copy(void* pSource, void* pDestination, size_t iNumberItems) const = 0;

		/// The Copy method copies iNumberItems from this buffer (starting at index iFrom) to pDestination (start at index iTo).
		/// <param name="iFrom">The starting index to copy data from this buffer.</param>
		/// <param name="pDestination">Buffer to copy data to.</param>
		/// <param name="iTo">The starting index to copy data to the pDestination buffer.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// <remarks>The pDestination buffer must be an instance of the same class as this buffer.</remarks>
		virtual void Copy(size_t iFrom, CircularBufferBase* pDestination, size_t iTo, size_t iNumberElements) const = 0;

		/// The Zero method zeros the specified number of items from this buffer starting at the specified index.
		/// <param name="iStart">The starting index to start zeroing the buffer.</param>
		/// <param name="iNumberItems">The number of items to copy.</param>
		/// <param name="pReference">A pointer to reference data to copy attributes from such as fixed-point precision, matrix dimensionality, and carrier frequency.</param>
		virtual bool Zero(size_t iStart, size_t iNumberItems, void* pReference) = 0;

		/// The Initialize method will set all of the items in the buffer to zero.
		void Initialize()
		{
			Zero(0,m_iSize,0);
		}

		/// The Advance method increments the m_iCurrent location in the buffer by the rate specified when the SetBuffer method was called.  This method is called for all DFPorts after each <c>DFModel::Run</c> method is called. 
		inline void Advance()
		{
			_ASSERT( m_pBuffer); // Why are we advancing a pointer on a buffer that contains no data?

			m_iCurrent = IndexAt(m_iRate); 
		};

		/// The SetContiguousProperty declares that the circular buffer will support reading/writing contiguous sections in the buffer.
		/// <remarks>This method should be called in the setup method.</remarks>
		void SetContiguousProperty() 
		{
			_ASSERT( m_pBuffer == 0); // Must be set before the memory is allocated

			m_bContiguousBuffer = true; 
		}

		/// <remarks>This method returns true if the circular buffer supports reading/writing contiguous sections in the buffer.</remarks>
		bool GetContiguousProperty() const
		{
			return m_bContiguousBuffer; 
		}

		/// The GetReadPtr method is used to get a pointer to read from in a contiguous manner.
		/// <returns>Returns a <c>void*</c> to the location to read from.</returns>
		void* GetReadPtr()
		{
			_ASSERT( m_bContiguousBuffer); // Must have set the contiguous buffer parameter in your Setup method

			// Determine where the the contiguous buffer ends
			size_t iEnd = m_iCurrent + m_iRate;
	
			// If it ends after the end of the circular buffer, we must copy the data
			if ( iEnd >= m_iSize)
				Copy( m_pBuffer,GetPointer(m_iSize),m_iSize - iEnd + 1);

			return GetPointer(m_iCurrent);
		}

		/// The GetWritePtr method is used to get a pointer to write to in a contiguous manner.
		/// <returns>Returns a <c>void*</c> to the location to write to.</returns>
		/// <remarks>You must call the Write method to copy the data from the contiguous memory into the circular buffer.</remarks>
		void* GetWritePtr()
		{
			_ASSERT( m_bContiguousBuffer); // Must have set the contiguous buffer parameter in your Setup method
			return GetPointer(m_iCurrent);
		}

		/// The Write method copies data from the contiguous buffer to the circular buffer.
		void Write()
		{
			_ASSERT( m_bContiguousBuffer); // Must have set the contiguous buffer parameter in your Setup method

			size_t iEnd = m_iCurrent + m_iRate;

			if ( iEnd >= m_iSize)
				Copy( GetPointer(m_iSize),m_pBuffer,m_iSize - iEnd + 1);
		}

		/// Get a pointer to the buffer at the specified index
		void* GetPointer(size_t iIndex)
		{
			_ASSERT( m_pBuffer); // The buffer must be allocated before you can call this method
			return &((char*)m_pBuffer)[m_iSizeOf * IndexAt(iIndex)];
		}

		/// Get the pointer to the start of the circular buffer memory.
		/// <returns>Returns a <c>void*</c> of the circular buffer memory.</returns>
		void* GetBufferMemory()
		{
			return m_pBuffer;
		}

		/// <returns> Returns true if connected (buffer has the memory) false otherwise. A Model must call it only inside model's Run() method.</returns>
		bool IsConnected()
		{
			return (m_pBuffer != 0);
		}

		/// <returns>Returns the index of the current element in the buffer memory.</returns>
		size_t GetCurrentIndex() const { return m_iCurrent; }

		/// <returns>Returns the size of each element.</returns>
		size_t GetSizeOf() const { return m_iSizeOf; }

		/// <returns>Returns the number of items the circular buffer can hold.</returns>
		size_t GetSize() const
		{
			return m_iSize;
		}

		// Function to return index taking into account the circular nature of the buffer
		inline size_t IndexAt(size_t iIndex) const
		{
			_ASSERT( iIndex < 2*m_iSize); // We don't use modulo to wrap-around for efficiency - your iIndex must be < 2*m_iSize
			if ( iIndex ==0)
			{
				iIndex = m_iCurrent;
			}
			else
			{
				iIndex = m_iCurrent + iIndex;
				if ( iIndex >= m_iSize)
				{
					iIndex=iIndex-m_iSize;

					_ASSERT( iIndex < m_iSize); // Circular indexing only works for one wraparound on the circular buffer

				}
			}
			return iIndex;
		};

	protected:

		// Advance rate of the buffer
		size_t m_iRate;

		// The total number of samples that can be indexed the index [0] will mean the oldest sample in the history
		// This value must be greater than or equal to m_iRate
		size_t m_iHistoryDepth;

		bool m_bContiguousBuffer;

		size_t m_iSizeOf;

		/// The actual current location in the buffer.  You should not change this as it is automatically managed for you for all DFPorts.
		size_t m_iCurrent;

		// Pointer to the buffer memory
		void* m_pBuffer;

		// Size of the buffer
		size_t m_iSize;

	};

	/// The CircularBuffer template class allows your models to make efficient use of circular buffers for input and output ports of types that can use memcpy (shallow copy)
	template <typename T> class CircularBuffer: public CircularBufferBase
	{
	public:
		CircularBuffer():CircularBufferBase()
		{
			m_iSizeOf = sizeof(T);
		}

		/// <summary>
		/// The Copy method copies iNumberItems from pSource to pDestination.
		/// <param name="pSource">Pointer to thebuffer to copy data from. </param>
		/// <param name="pDestination">Pointer to the buffer to copy data to.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		virtual void Copy(void* pSource, void* pDestination, size_t iNumberItems) const
		{
			_ASSERT( pSource && pDestination && iNumberItems > 0);

			T* pDst = (T*)pDestination;
			T* pSrc = (T*)pSource;

			memcpy( pDestination, pSource, iNumberItems*sizeof(T));
		}

		/// <summary>
		/// The Copy method copies iNumberItems from this buffer (starting at index iFrom) to a pDestination.
		/// <param name="iFrom">The starting index to copy data from this buffer.</param>
		/// <param name="pDestination">Pointer to a buffer to copy data to.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		void Copy(size_t iFrom, T* pDestination, size_t iNumberItems) const
		{
			_ASSERT( pDestination && iNumberItems <= m_iSize);

			T* pSource = (T*)m_pBuffer;
			iFrom = IndexAt(iFrom);

			size_t iTo = 0;
			if ( iNumberItems==1)
			{
				pDestination[iTo] = pSource[iFrom];
			}
			else
			{
				while ( iNumberItems>0)
				{
					size_t iCopy = std::min( iNumberItems, m_iSize - iFrom);
					memcpy( &pDestination[iTo], &(pSource[iFrom]), iCopy*sizeof(T));
					iFrom += iCopy;
					iTo += iCopy;
					if ( iFrom == m_iSize) iFrom = 0;
					iNumberItems -= iCopy;
				}
			}
		}

		/// <summary>
		/// The Copy method copies iNumberItems from this buffer (starting at index iFrom) to pDestination (start at index iTo).
		/// <param name="iFrom">The starting index to copy data from this buffer.</param>
		/// <param name="pDestination">Pointer to a CircularBuffer to copy data to.</param>
		/// <param name="iTo">The starting index to copy data to the pDestination buffer.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		void Copy(size_t iFrom, CircularBufferBase* pDestination, size_t iTo, size_t iNumberItems) const
		{
			_ASSERT( dynamic_cast<CircularBuffer<T>*>(pDestination));  // Copy can only be done on circular buffers of the same class

			_ASSERT( iNumberItems <= m_iSize && iNumberItems <= pDestination->GetSize());  // Should only copy less items than either buffer can hold

			T* pFrom = (T*)(m_pBuffer);
			T* pTo = (T*)(pDestination->GetBufferMemory());
			iFrom = IndexAt(iFrom);
			iTo = pDestination->IndexAt(iTo);

			if ( iNumberItems==1)
			{
				pTo[iTo] = pFrom[iFrom];
			}
			else
			{
				size_t iSizeFrom = m_iSize;
				size_t iSizeTo = pDestination->GetSize();
				size_t iCopy;
				while ( iNumberItems>0)
				{
					iCopy = (std::min)( (std::min)( iNumberItems, iSizeFrom - iFrom), iSizeTo - iTo);
					memcpy( &(pTo)[iTo], &(pFrom)[iFrom], iCopy*sizeof(T));
					iTo += iCopy;
					if ( iTo == iSizeTo) iTo = 0;
					iFrom += iCopy;
					if ( iFrom == iSizeFrom) iFrom = 0;
					iNumberItems -= iCopy;
				}
			}
		}

		/// The Zero method zeros the specified number of items from this buffer starting at the specified index.
		/// <param name="iStart">The starting index to start zeroing the buffer.</param>
		/// <param name="iNumberItems">The number of items to copy.</param>
		/// <param name="pReference">Ignored.</param>
		bool Zero(size_t iStart, size_t iNumberItems = 1, void* pReference = 0)
		{
			_ASSERT( iStart < m_iSize && iNumberItems <= m_iSize);

			CircularBuffer<T>& buf = *this;
			while( iNumberItems--)
			{
				buf[iStart++] = T(0);
			}
			return true;
		}

		/// Reading and writing to the buffer locations is done in the same way as you would with a <c>double*</c>.
		inline T& operator[](size_t iIndex)
		{
			_ASSERT( m_pBuffer);   // Should have been set by call to SetBuffer
			return ((T*)m_pBuffer)[IndexAt(iIndex)];
		}

	};

	/// The CircularBuffer class allows your models to make efficient use of circular buffers for input and output ports of type <c>double*</c>.
	template <typename T> class CircularBufferE: public CircularBufferBase
	{
	public:
		CircularBufferE():CircularBufferBase()
		{
			m_iSizeOf = sizeof(T);
		}

		/// <summary>
		/// The Copy method copies iNumberItems from pSource to pDestination.
		/// <param name="pSource">Pointer to thebuffer to copy data from. </param>
		/// <param name="pDestination">Pointer to the buffer to copy data to.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		void Copy(void* pSource, void* pDestination, size_t iNumberItems) const
		{
			_ASSERT( pSource && pDestination && iNumberItems > 0);

			size_t i;
			T* pDest = (T*)pDestination;
			T* pSrc  = (T*)pSource;
			for ( i = 0; i < iNumberItems; i++)
				(*(pDest++)) = (*(pSrc++));
		}

		/// <summary>
		/// The Copy method copies iNumberItems from this buffer (starting at index iFrom) to a pDestination.
		/// <param name="iFrom">The starting index to copy data from this buffer.</param>
		/// <param name="pDestination">Pointer to a buffer to copy data to.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		void Copy(size_t iFrom, void* pDestination, size_t iNumberItems) const
		{
			_ASSERT( pDestination && iNumberItems <= m_iSize && iFrom < iNumberItems);

			size_t i;
			T* pDest = (T*)pDestination;
			for ( i = iFrom; i < iFrom + iNumberItems; i++)
				(*(pDest++)) = (*this)[i];
		}

		/// <summary>
		/// The Copy method copies iNumberItems from this buffer (starting at index iFrom) to pDestination (start at index iTo).
		/// <param name="iFrom">The starting index to copy data from this buffer.</param>
		/// <param name="pDestination">Pointer to a CircularBuffer to copy data to.</param>
		/// <param name="iTo">The starting index to copy data to the pDestination buffer.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// </summary>
		void Copy(size_t iFrom, CircularBufferBase* pDestination, size_t iTo, size_t iNumberItems) const
		{
			_ASSERT( dynamic_cast<CircularBufferE<T>*>(pDestination));  // Only copy between buffers that are of the same type
			_ASSERT( iNumberItems <= m_iSize && iNumberItems <= pDestination->GetSize());

			CircularBufferE<T>* pDest = (CircularBufferE<T>*)pDestination;
			const CircularBufferE<T>* pSrc = this;
			while( iNumberItems--)
			{
				(*pDest)[iTo++] = (*pSrc)[iFrom++];
			}
		}

		/// The Zero method zeros the specified number of items from this buffer starting at the specified index.
		/// <param name="iStart">The starting index to start zeroing the buffer.</param>
		/// <param name="iNumberItems">The number of items to copy.</param>
		/// <param name="pReference">A pointer to reference data to copy attributes from such as fixed-point precision, matrix dimensionality, and carrier frequency.</param>
		bool Zero(size_t iStart, size_t iNumberItems, void* pReference)
		{
			_ASSERT( iNumberItems <= m_iSize);
			_ASSERT( iStart < m_iSize);

			CircularBufferE<T>& buf = *this;
			bool bSuccess = true;
			while( iNumberItems-- && bSuccess)
			{
				bSuccess = buf[iStart++].Zero((T*)pReference);
			}
			return bSuccess;
		}

		/// Reading and writing to the buffer locations is done in the same way as you would with a <c>double*</c>.
		inline T& operator[](size_t iIndex)
		{
			_ASSERT( iIndex < m_iSize);
			_ASSERT( m_pBuffer);				// Should have been set in SetBuffer
			return ((T*)m_pBuffer)[IndexAt(iIndex)];
		}

		/// Reading and writing to the buffer locations is done in the same way as you would with a <c>double*</c>.
		inline const T& operator[](size_t iIndex) const
		{
			_ASSERT( iIndex < m_iSize);
			_ASSERT( m_pBuffer);				// Should have been set in SetBuffer
			return ((T*)m_pBuffer)[IndexAt(iIndex)];
		}

	};

	/// The CircularBufferBus class allows your models to have bus ports - this is the abstract base class, you should use the typedefs below.
	class CircularBufferBus
	{
	public:

		/// The Initialize method resizes the bus.  This is called by SystemVue based on the number of connections.
		/// <param name="iSize">The new size of the bus.</param>
		virtual void Initialize(size_t iNumberItems) = 0;

		/// Delete all of the bus circular buffers
		virtual ~CircularBufferBus() {};

		/// <returns>Returns the size of the bus.</returns>
		size_t GetSize() const { return m_iSize; } 

		/// The Get method returns the CircularBuffer at the specified index.
		/// <param name="iIndex">Index of the bus port.</param>
		/// <returns>Returns the CircularBuffer at the specified index.</returns>
		virtual CircularBufferBase* Get(size_t iIndex) = 0;

	protected:
		size_t m_iSize;
	};

	/// The CircularBufferBusT class allows your models to have bus ports of specific types.  You should use the typedefs below.
	template <typename T> class CircularBufferBusT: public CircularBufferBus
	{
	public:

		/// Constructor
		CircularBufferBusT() 
		{
			m_pCirBufBus = 0;
			m_iSize = 0;
		}

		/// Delete all of the bus circular buffers
		virtual ~CircularBufferBusT() 
		{
			delete [] m_pCirBufBus;
		}

		/// The Initialize method resizes the bus.  This is called by SystemVue based on the number of connections.
		/// <param name="iSize">The new size of the bus.</param>
		void Initialize(size_t iSize)
		{
			if ( m_iSize != iSize)
			{
				delete [] m_pCirBufBus;
				m_pCirBufBus = 0;  // m_iSize = 0 will delete the buffer 

				m_iSize = iSize;
				if (m_iSize) m_pCirBufBus = new T[m_iSize];
			}
		}

		/// The Get method returns the CircularBuffer at the specified index.
		/// <param name="iIndex">Index of the bus port.</param>
		/// <returns>Returns the CircularBuffer at the specified index.</returns>
		const T& operator[](size_t iIndex) const
		{
			_ASSERT( iIndex < m_iSize);
			return m_pCirBufBus[iIndex];
		}

		/// The Get method returns the CircularBuffer at the specified index.
		/// <param name="iIndex">Index of the bus port.</param>
		/// <returns>Returns the CircularBuffer at the specified index.</returns>
		T& operator[](size_t iIndex)
		{
			_ASSERT( iIndex < m_iSize);
			return m_pCirBufBus[iIndex];
		}

	private:

		/// The GetCircularBufferBase method returns the CircularBuffer at the specified index.  You should use the Get() method instead in your model code.
		/// <param name="iIndex">Index of the bus port.</param>
		/// <returns>Returns the CircularBuffer at the specified index.</returns>
		CircularBufferBase* Get(size_t iIndex)
		{
			_ASSERT( iIndex < m_iSize);
			return &(*this)[ iIndex];
		}

		T* m_pCirBufBus;
	};

	/* ********************************************************************** */
	// Integer
	/* ********************************************************************** */
	/// Circular buffer for integer data type
	typedef CircularBuffer<int> IntCircularBuffer;
	/// Circular buffer bus for integer data type
	typedef CircularBufferBusT<IntCircularBuffer> IntCircularBufferBus;


	/* ********************************************************************** */
	// Double
	/* ********************************************************************** */
	/// Circular buffer for double data type
	typedef CircularBuffer<double> DoubleCircularBuffer;
	/// Circular buffer bus for integer data type
	typedef CircularBufferBusT<DoubleCircularBuffer> DoubleCircularBufferBus;


	/* ********************************************************************** */
	// Complex double
	/* ********************************************************************** */
	/// Circular buffer for complex double data type
	typedef CircularBuffer<std::complex<double>> DComplexCircularBuffer;
	/// Circular buffer bus for integer data type
	typedef CircularBufferBusT<DComplexCircularBuffer> DComplexCircularBufferBus;

	/* ********************************************************************** */
	// Float
	/* ********************************************************************** */
	/// Circular buffer for float data type
	typedef CircularBuffer<float> FloatCircularBuffer;
	/// Circular buffer bus for integer data type
	typedef CircularBufferBusT<FloatCircularBuffer> FloatCircularBufferBus;

	/* ********************************************************************** */
	// Complex float 
	/* ********************************************************************** */
	/// Circular buffer for complex float data type
	typedef CircularBuffer<std::complex<float>> FComplexCircularBuffer;
	/// Circular buffer bus for integer data type
	typedef CircularBufferBusT<FComplexCircularBuffer> FComplexCircularBufferBus;

}
