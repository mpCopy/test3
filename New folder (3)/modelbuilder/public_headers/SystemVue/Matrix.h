// Copyright  2009 - 2017 Keysight Technologies, Inc
#pragma once
#include <complex>
#include <crtdbg.h>
#include <algorithm>
namespace SystemVueModelBuilder
{

	template <typename T> class Matrix
	{
	public:

		Matrix()
		{
			Initialize();
		}

		~Matrix()
		{
			delete [] m_pData;
		}

		/// Return uninitialized matrix
		Matrix(size_t nRows, size_t nCols)
		{
			Initialize();
			Resize(nRows,nCols);
		}

		Matrix(const Matrix & matrix)
		{
			Initialize();
			*this = matrix;
		}

		void Resize( size_t nRows, size_t nCols)
		{
			m_iNumRows = nRows;
			m_iNumColumns = nCols;
			m_iNumElements = m_iNumRows*m_iNumColumns;
			if ( m_iNumElements > 0 && m_iNumElements > m_iMaxElements )
			{
				SetMaxElements( m_iNumElements);
			}
		}

		/// Return the number of columns
		inline size_t NumColumns() const { return m_iNumColumns; }

		/// Return the number of rows
		inline size_t NumRows() const { return m_iNumRows; }

		inline size_t NumElements() const { return m_iNumElements; }

		inline void SetMaxElements( size_t iMaxElements)
		{
			if ( m_iMaxElements != iMaxElements)
			{
				m_iMaxElements = iMaxElements;
				delete [] m_pData;
				if ( m_iMaxElements > 0)
					m_pData = new T[ m_iMaxElements];
				else
					m_pData = 0;
			}
		}

		/// Set all elements to zero
		bool Zero()
		{
			size_t i;
			for ( i = 0 ; i < m_iNumElements; i++)
				m_pData[i] = 0;
			return true;
		}

		/// Sets dimensions relative to a reference matrix, if null set to empty matrix
		bool Zero(Matrix* pReference)
		{
			if ( pReference)
			{
				Resize( pReference->m_iNumRows, pReference->m_iNumColumns);
				Zero();
			}
			else
			{
				Resize(0,0);
			}
			return true;
		}

		/// Return TRUE if this matrix is equal to another
		bool operator == (const Matrix & matrix) const
		{
			bool bIsEqual = (m_iNumRows==matrix.NumRows() && m_iNumColumns==matrix.NumColumns());
			size_t i;

			// The "&& bIsEqual" will break out of the loop as soon as two corresponding matrix entries are different.
			for (i=0; i< NumElements() && bIsEqual; i++)
			{
				bIsEqual = ( operator()(i)==matrix(i) );
			}
			return bIsEqual;
		}

		/// Return TRUE if this matrix is not equal to another
		bool operator != (const Matrix & matrix) const
		{
			return ! ( *this == matrix );
		}

		Matrix& operator = (const Matrix& matrix)
		{
			Resize( matrix.NumRows(), matrix.NumColumns());

			if ( matrix.NumElements() > 0)
			{
				_ASSERT( matrix.NumElements()==NumElements() && m_pData);
				matrix.CopyTo(m_pData, matrix.NumElements());
			}

			return *this;
		};

		/// Resize array before use of this function
		void CopyFrom(const T* pData, size_t iSize)
		{
			_ASSERT( pData != 0);
			memcpy(m_pData,pData,(std::min)(NumElements(),iSize)*sizeof(T));
			if ( NumElements() > iSize)
			{
				for ( size_t i = iSize ; i < NumElements(); i++)
					m_pData[i] = T(0);
			}
		}

		void CopyTo(T* pData, size_t iSize) const
		{
			_ASSERT( pData != 0);
			memcpy(pData,m_pData,(std::min)(NumElements(),iSize)*sizeof(T));
			if ( iSize > NumElements() )
			{
				for ( size_t i = NumElements() ; i < iSize; i++)
					pData[i] = T(0);
			}
		}

		T& operator() ( size_t iRow, size_t iCol)
		{
			_ASSERT( m_pData && NumElements());
			_ASSERT( iRow < m_iNumRows);
			_ASSERT( iCol < m_iNumColumns);
			size_t iIndex = m_iNumRows*iCol+iRow;
			return m_pData[iIndex];
		}

		T operator() ( size_t iRow, size_t iCol) const
		{
			_ASSERT( m_pData && NumElements());
			_ASSERT( iRow < m_iNumRows);
			_ASSERT( iCol < m_iNumColumns);
			size_t iIndex = m_iNumRows*iCol+iRow;
			return m_pData[iIndex];
		}

		T& operator() ( size_t iIndex)
		{
			_ASSERT( m_pData && NumElements());
			_ASSERT( iIndex < NumElements());
			return m_pData[iIndex];
		}

		T operator() ( size_t iIndex) const
		{
			_ASSERT( m_pData && NumElements());
			_ASSERT( iIndex < NumElements());
			return m_pData[iIndex];
		}

		Matrix& negate() 
		{
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] = - m_pData[i];
			return *this;
		}

		template<typename S> Matrix& operator+= (S scalar)
		{
			_ASSERT( NumElements() > 0);
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] += scalar;
			return *this;
		}

		template<typename M> Matrix& operator+= (const Matrix<M>& matrix)
		{
			_ASSERT( NumRows() == matrix.NumRows() && NumColumns() == matrix.NumColumns());
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] += matrix(i);
			return *this;
		}

		template<typename S> Matrix& operator-= (S scalar)
		{
			_ASSERT( NumElements() > 0);
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] -= scalar;
			return *this;
		}

		template<typename M> Matrix& operator-= (const Matrix<M>& matrix)
		{
			_ASSERT( NumRows() == matrix.NumRows() && NumColumns() == matrix.NumColumns());
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] -= matrix(i);
			return *this;
		}

		template<typename S> Matrix& operator*= (S scalar)
		{
			_ASSERT( NumElements() > 0);
			for ( size_t i = 0 ; i < NumElements() ; i++)
				m_pData[i] *= scalar;
			return *this;
		}

		/// make this a diagonal matrix
		bool diagonal(T data)
		{
			bool bResult = m_iNumRows == m_iNumColumns;
			if ( bResult)
			{
				size_t i,j,k=0;
				for ( j = 0; j < m_iNumColumns  ; j++)
					for ( i = 0; i < m_iNumRows  ; i++)
						m_pData[k++] = (i==j? data:(T)0);
			}
			return bResult;
		}

		/// make this a identity matrix
		bool identity()
		{
			return diagonal(1);
		}

		T* GetBuffer()
		{
			return m_pData;
		}

		const T* GetBuffer() const
		{
			return m_pData;
		}

		void Swap(Matrix& pMatrix)
		{
			T* pData = m_pData;
			size_t iMaxElements = m_iMaxElements;
			size_t iNumRows = m_iNumRows;
			size_t iNumColumns = m_iNumColumns;
			size_t iNumElements = m_iNumElements;			

			m_pData = pMatrix->m_pData;
			m_iMaxElements = pMatrix->m_iMaxElements;
			m_iNumRows = pMatrix->m_iNumRows;
			m_iNumColumns = pMatrix->m_iNumColumns;
			m_iNumElements = pMatrix->m_iNumElements;			

			pMatrix->m_pData = pData;
			pMatrix->m_iMaxElements = iMaxElements;
			pMatrix->m_iNumRows = iNumRows;
			pMatrix->m_iNumColumns = iNumColumns;
			pMatrix->m_iNumElements = iNumElements;			
		}

	private:
		T* m_pData;
		size_t m_iNumRows;
		size_t m_iNumColumns;
		size_t m_iNumElements;
		size_t m_iMaxElements;

		void Initialize()
		{
			m_pData=0;
			m_iMaxElements = 0;
			m_iNumRows = 0;
			m_iNumColumns = 0;
			m_iNumElements = 0;
		}

	};

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator + (const Matrix<M2> &mx1, const Matrix<M3> &mx2) 
	{
		Matrix<M1> result;
		_ASSERT(mx1.NumColumns() == m2.NumColumns() && mx1.NumRows() == mx2.NumRows());

		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx1(i) + mx2(i);

		return result;
	}

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator + (const Matrix<M2> &mx1, const M3 &mx2) 
	{
		Matrix<M1> result;
		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx1(i) + mx2;

		return result;
	}

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator + (const M3 &mx2, const Matrix<M2> &mx1) 
	{
		Matrix<M1> result;
		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx1(i) + mx2;

		return result;
	}

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator - (const Matrix<M2> &mx1, const Matrix<M3> &mx2) 
	{
		Matrix<M1> result;
		_ASSERT(mx1.NumColumns() == m2.NumColumns() && mx1.NumRows() == mx2.NumRows());

		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx1(i) - mx2(i);

		return result;
	}

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator - (const Matrix<M2> &mx1, const M3 &mx2) 
	{
		Matrix<M1> result;
		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx1(i) - mx2;

		return result;
	}

	template <typename M1, typename M2, typename M3> 
	Matrix<M1> operator - (const M3 &mx2, const Matrix<M2> &mx1) 
	{
		Matrix<M1> result;
		result.Resize(mx1.NumRows(),mx1.NumColumns());

		size_t i;
		for (i = 0 ; i < mx1.NumElements(); i++)
			result(i) = mx2 - mx1(i);

		return result;
	}

	typedef Matrix<int> IntMatrix;
	typedef Matrix<double> DoubleMatrix;
	typedef Matrix<std::complex<double>> DComplexMatrix;

}
