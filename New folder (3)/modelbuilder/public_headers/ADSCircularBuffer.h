#ifndef ADSCircularBuffer_H
#define ADSCircularBuffer_H
// Copyright  2009 - 2017 Keysight Technologies, Inc  

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//-----------------------------------------------------------------------------------

#include "CommonBase.h"
#include <algorithm>
#include <complex>
#include "SDFPortHole.h"

#ifdef WIN32
#include <crtdbg.h>
#else
#ifndef _ASSERT
#include <assert.h>
#define _ASSERT assert
#endif
#endif

using namespace ADSPtolemy;

namespace SystemVueModelBuilder
{

	template <typename T> class ParticleWrapper
	{
	public:
		ParticleWrapper()
		{
			m_pParticle = 0;
		}

		ParticleWrapper(const ParticleWrapper& p)
		{
			m_pParticle = p.m_pParticle;
		}

		ParticleWrapper(Particle& p)
		{
			m_pParticle = &p;
		}

		operator T() 
		{ 
			_ASSERT( m_pParticle);
			return *m_pParticle; 
		}

		T operator =(T value) 
		{ 
			*m_pParticle << value; 
			return value;
		}

	private:
		Particle* m_pParticle;
	};

	//specialization for std::complex<double>
	template <> class ParticleWrapper<std::complex<double> >
	{
	public:
		ParticleWrapper()
		{
			m_pParticle = 0;
		}

		ParticleWrapper(const ParticleWrapper& p)
		{
			m_pParticle = p.m_pParticle;
		}

		ParticleWrapper(Particle& p)
		{
			m_pParticle = &p;
		}

		operator std::complex<double>() 
		{
			_ASSERT( m_pParticle);
			if ( m_pParticle->type() == COMPLEX) {
				Complex tmp = *(dynamic_cast<ComplexParticle *>(m_pParticle));
				return std::complex<double>(tmp.real(), tmp.imag());
			}
			else
				return std::complex<double>(*m_pParticle, 0);
		}

		std::complex<double> operator =(std::complex<double> value) 
		{ 
			*m_pParticle << Complex(value.real(), value.imag()); 
			return value;
		}

	private:
		Particle* m_pParticle;
	};

	/// The CircularBuffer class enables your models to use circular buffers to implement your DFPorts.
	/// <remarks>The CircularBuffer class is an abstract base class.</remarks>
	class MODELBUILDER_API CircularBufferBase
	{
	public:

		/// Constructor
		CircularBufferBase(DataTypeE eDataType)
		{
			m_eDataType = eDataType;
			m_pPort = 0;
			m_iHistoryDepth = 1;
		}

		/// Constructor
		CircularBufferBase()
		{
			m_pPort = 0;
			m_iHistoryDepth = 1;
		}

		/// Virtual Destructor
		virtual ~CircularBufferBase() {}

		/// The SetRate method sets the multirate property on the CircularBuffer.  This should only be called in the Setup method.
		/// <param name="iRate">The multirate value (i.e. number produced / consumed each invocation of your model).</param>
		void SetRate( size_t iRate)
		{
			_ASSERT( m_pPort);
			m_pPort->setSDFParams(iRate,iRate-1);
			if(m_iHistoryDepth < iRate)
			{
				m_iHistoryDepth = iRate;
			}
		}

		/// The GetRate method gets the multirate property on the CircularBuffer. 
		/// <param name="iRate">The multirate value (i.e. number produced / consumed each invocation of your model).</param>
		inline size_t GetRate() const
		{
			_ASSERT( m_pPort);
			return m_pPort->numXfer();
		}

		/// The SetHistoryDepth method sets the total number of samples that can be indexed by CircularBuffer. 
		/// The index [0] will point to the oldest sample in the history. By default the HistoryDepth is equal to
		/// multi-rate value. This method should only be called in the Setup method.
		/// <param name="iHistoryDepth">The total number of samples that can be indexed by CircularBuffer.</param> 
		void SetHistoryDepth(size_t iHistoryDepth)
		{
			// Tap delay line size must be greater than multirate value
			_ASSERT(iHistoryDepth > GetRate()); 

			m_iHistoryDepth = iHistoryDepth;
		}

		/// The total number of samples that can be indexed by CircularBuffer.
		/// The index [0] will point to the oldest sample in the history.
		size_t GetHistoryDepth()
		{
			return m_iHistoryDepth;
		}

		/// The Initialize method will set all of the items in the buffer to zero.
		void Initialize()
		{
			// In ADS - the Geodesic buffer is initialized by the target - no need to do it here
		}

		/// <returns> Returns true if connected (buffer has the memory) false otherwise. A Model must call it only inside model's Run() method.</returns>
		bool IsConnected()
		{
			return m_pPort!=0 && m_pPort->far()!= 0;
		}

		SDFPortHole* m_pPort;

		DataTypeE m_eDataType;

	protected:
		size_t m_iSizeOf;

		// The total number of samples that can be indexed the index [0] will mean the oldest sample in the history
		// This value must be greater than or equal to m_iRate
		size_t m_iHistoryDepth;
	};

	template <typename T, DataTypeE E_DATATYPE> class CircularBuffer: public CircularBufferBase
	{
	public:
		CircularBuffer()
		{
			m_eDataType = E_DATATYPE;
		}

		inline ParticleWrapper<T> operator[](size_t iIndex)
		{
			_ASSERT( iIndex < GetRate());
			_ASSERT( m_pPort);
			ParticleWrapper<T> particleWrapper((*m_pPort)%(GetRate()-1-iIndex));
			return particleWrapper;
		}

		inline const ParticleWrapper<T> operator[](size_t iIndex) const
		{
			_ASSERT( iIndex < GetRate());
			_ASSERT( m_pPort);
			ParticleWrapper<T> particleWrapper((*m_pPort)%(GetRate()-1-iIndex));
			return particleWrapper;
		}

	};

	/// The CircularBufferBus class allows your models to have bus ports - this is the abstract base class, you should use the typedefs below.
	class CircularBufferBus
	{
	public:

		CircularBufferBus()
		{
			m_pMultiPort = 0;
		}

		/// The Initialize method resizes the bus.  This is called by SystemVue based on the number of connections.
		/// <param name="iSize">The new size of the bus.</param>
		virtual void Initialize(size_t iNumberItems) = 0;

		/// Delete all of the bus circular buffers
		virtual ~CircularBufferBus() {};

		virtual CircularBufferBase* Get( size_t Index) = 0;

		/// <returns>Returns the size of the bus.</returns>
		size_t GetSize() const 
		{ 
			_ASSERT( m_pMultiPort);
			return m_pMultiPort->numberPorts();
		}

		SDFMultiPort* m_pMultiPort;

		DataTypeE m_eDataType;

	};

	template <typename T, DataTypeE E_DATATYPE> class CircularBufferBusT: public CircularBufferBus
	{
	public:

		/// Constructor
		CircularBufferBusT() 
		{
			m_eDataType = E_DATATYPE;
			m_pCirBufBus = 0;
			m_iSize = 0;
		}

		~CircularBufferBusT()
		{
			delete [] m_pCirBufBus;
		}

		void Initialize(size_t iSize)
		{
			_ASSERT( m_pMultiPort);
			_ASSERT( m_pMultiPort->numberPorts() == iSize);

			
			if ( iSize != m_iSize)
			{
				delete [] m_pCirBufBus;
				m_pCirBufBus = 0;  // m_iSize = 0 will delete the buffer 

				if (iSize) 
					m_pCirBufBus = new CircularBuffer<T,E_DATATYPE>[iSize];

				m_iSize = iSize;
			}

			{
				MPHIter nextPort(*m_pMultiPort);
				PortHole* pPort;
				size_t i = 0;
				while ( (pPort = nextPort++) != 0)
				{
					_ASSERT( dynamic_cast<SDFPortHole*>(pPort));
					m_pCirBufBus[i++].m_pPort = (SDFPortHole*) pPort;
				}
			}
		}

		/// Reading and writing to the buffer locations is done in the same way as you would with a <c>double*</c>.
		inline CircularBuffer<T,E_DATATYPE>& operator[](size_t iIndex)
		{
			_ASSERT( iIndex < m_iSize);   
			_ASSERT( m_pCirBufBus);
			return m_pCirBufBus[iIndex];
		}

		/// Reading and writing to the buffer locations is done in the same way as you would with a <c>double*</c>.
		inline const CircularBuffer<T,E_DATATYPE>& operator[](size_t iIndex) const
		{
			_ASSERT( iIndex < m_iSize);   
			_ASSERT( m_pCirBufBus);
			return m_pCirBufBus[iIndex];
		}

		CircularBufferBase* Get(size_t Index)
		{
			return &((*this)[Index]);
		}

	private:
		CircularBuffer<T,E_DATATYPE>* m_pCirBufBus;

		size_t m_iSize;
	};

	namespace CirBuf
	{

		/// The DetermineDataType function determines the data type based on a circular buffer.
		/// <param name="pCirBuf">The reference circular buffer.</param>
		/// <returns>Returns the data type.</returns>
		inline DataTypeE DetermineDataType(const SystemVueModelBuilder::CircularBufferBase* pCirBuf)
		{
			_ASSERT( pCirBuf);
			return pCirBuf->m_eDataType;
		}
	}

	/* ********************************************************************** */
	// Integer
	/* ********************************************************************** */
	typedef CircularBuffer<int,eInt>										IntCircularBuffer;
	typedef CircularBufferBusT<int,eInt>								IntCircularBufferBus;

	/* ********************************************************************** */
	// Double
	/* ********************************************************************** */
	typedef CircularBuffer<double,eDouble>								DoubleCircularBuffer;
	typedef CircularBufferBusT<double,eDouble>						DoubleCircularBufferBus;

	/* ********************************************************************** */
	// Complex double
	/* ********************************************************************** */
	typedef CircularBuffer<std::complex<double>,eComplex>			DComplexCircularBuffer;
	typedef CircularBufferBusT<std::complex<double>,eComplex>	DComplexCircularBufferBus;

	/* ********************************************************************** */
	// Float - in ADS we only use double
	/* ********************************************************************** */
	typedef DoubleCircularBuffer			FloatCircularBuffer;
	typedef DoubleCircularBufferBus		FloatCircularBufferBus;

	/* ********************************************************************** */
	// Complex float - in ADS we only use Complex double
	/* ********************************************************************** */
	typedef DComplexCircularBuffer		FComplexCircularBuffer;
	typedef DComplexCircularBufferBus	FComplexCircularBufferBus;


}

#endif // ADSCircularBuffer_H
