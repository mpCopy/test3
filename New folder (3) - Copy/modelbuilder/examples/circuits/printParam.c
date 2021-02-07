/* Copyright Keysight Technologies 2010 - 2011 */ 
/* sample code on how to access parameters */

#if 0

void print_ucm_params( const UserInstDef *userInst )
{
    int numParams = get_ucm_num_of_params( userInst );
    fprintf( stderr, "NumParams = %d\n", numParams );
    for( int paramIndex = 0; paramIndex < numParams; paramIndex++ )
    {
        const char *paramName = get_ucm_param_name( userInst, paramIndex );
        if( is_ucm_repeat_param( userInst, paramIndex ) )
        {
            int numRepeats = get_ucm_param_num_repeats( userInst, paramIndex );
            for( int repeatIndex = 0; repeatIndex < numRepeats; repeatIndex++ )
            {
                char errorMsg[2048];
                const SENIOR_USER_DATA *param = get_ucm_param_ptr( userInst,
                               paramIndex, errorMsg, repeatIndex );
                if( param )
                {
                    fprintf( stderr, "%s[%d]=", paramName, repeatIndex );
                    print_ucm_param_value( stderr, param );
                }
                else
                    fprintf( stderr, "Error: %s\n", errorMsg );
            }
        }
        else
        {
            char errorMsg[2048];
            /* for non-repeat parameter, set repeatIndex to -1 */
            const SENIOR_USER_DATA *param = get_ucm_param_ptr( userInst,
                           paramIndex, errorMsg, -1 );
            if( param )
            {
                fprintf( stderr, "%s=", paramName );
                print_ucm_param_value( stderr, param );
            }
            else
                fprintf( stderr, "Error: %s\n", errorMsg );
        }
    }
}



/* This is the copy of print_ucm_param_value( ). Please don't redefine 
   the function. The function is listed here as sample code on how to query 
   parameter type/value.
*/
void
print_ucm_param_value( FILE *fp, const SENIOR_USER_DATA *param )
{
    if( !fp )
        fp = stderr;

    if( !param )
    {
        fprintf( fp, "NULL\n" );
        return;
    }
    char errorMsg[2048];
    BOOLEAN status;
    DataTypeE datatype = get_ucm_param_data_type( param );
    if( datatype == INT_data )
    {
        int value = get_ucm_param_int_value( param, &status, errorMsg );
        if( !status )
            fprintf( fp, "Error: %s\n", errorMsg );
        else
            fprintf( fp, "%d(int)\n", value );
    }
    else if( datatype == REAL_data )
    {
        double value = get_ucm_param_real_value( param, &status, errorMsg );
        if( !status )
            fprintf( fp, "Error: %s\n", errorMsg );
        else
            fprintf( fp, "%g(real)\n", value );
    }
    else if( datatype == CMPLX_data )
    {
        ComplexNumber value = get_ucm_param_complex_value( param, 
                                                    &status, errorMsg );
        if( !status )
            fprintf( fp, "Error: %s\n", errorMsg );
        else
            fprintf( fp, "(%g,%g)(complex)\n", value.Real, value.Imag );
    }
    else if( datatype == STRG_data || datatype == MTRL_data )
    {
        const char* value = get_ucm_param_string_value( param, 
                                                    &status, errorMsg );
        if( !status )
            fprintf( fp, "Error: %s\n", errorMsg );
        else
            fprintf( fp, "%s(string)\n", value );

    }
    else if( datatype == INT_VECTOR_data )
    {
        int size = get_ucm_param_vector_size( param );

        fprintf( fp, "list[" );
        for( int index = 0; index < size; index++ )
        {
            int value = get_ucm_param_vector_int_value( param, index,
                                                &status, errorMsg );
            if( !status )
                fprintf( fp, " N/A", errorMsg );
            else
                fprintf( fp, " %d", value );
            if( index != size-1 )
                fprintf( fp, "," );
        }
        fprintf( fp, " ](int_array)\n");
    }
    else if( datatype == REAL_VECTOR_data )
    {
        int size = get_ucm_param_vector_size( param );

        fprintf( fp, "list[" );
        for( int index = 0; index < size; index++ )
        {
            double value = get_ucm_param_vector_real_value( param, index,
                                                &status, errorMsg );
            if( !status )
                fprintf( fp, " N/A", errorMsg );
            else
                fprintf( fp, " %g", value );
            if( index != size-1 )
                fprintf( fp, "," );
        }
        fprintf( fp, " ](real_array)\n");
    }
    else if( datatype == CMPLX_VECTOR_data )
    {
        int size = get_ucm_param_vector_size( param );

        fprintf( fp, "list[" );
        for( int index = 0; index < size; index++ )
        {
            ComplexNumber value = get_ucm_param_vector_complex_value( param, index,
                                                &status, errorMsg );
            if( !status )
                fprintf( fp, " N/A", errorMsg );
            else
                fprintf( fp, " (%g,%g)", value.Real, value.Imag );
            if( index != size-1 )
                fprintf( fp, "," );
        }
        fprintf( fp, " ](complex_array)\n");
    }
    else if( datatype == REPEAT_param )
        fprintf( fp, "Repeated param\n" );
    else
        fprintf( fp, "Error: Unknown type\n" );
}

#endif
