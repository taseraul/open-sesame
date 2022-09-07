/*
 * $projectname$.cpp
 *
 * Created: $date$
 * Author : $user$
 */ 

#include "sam.h"
#include "sysclk_helper.hpp"


int main(void)
{
    PORT->Group[0].DIRSET.reg = PORT_PA28;
    
    initializeSystemFor48MHz();

    /* Replace with your application code */
    uint8_t test =0;
    while (1) 
    {
        test++;
    }
    return 1;
}
