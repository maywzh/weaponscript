

For 1st person muzzle flash, use .qc to add particle effect into fire and/or fire_layer sequences, like:

{ event AE_CL_CREATE_PARTICLE_EFFECT 0 "<effect name here> follow_attachment muzzle_flash" }

example:

{ event AE_CL_CREATE_PARTICLE_EFFECT 0 "<effect name here> follow_attachment muzzle_flash" }




Don't forget to delete/comment original effect, if that's your desire ( but it also removes the bright flash that bounces off the walls):

//{ event AE_MUZZLEFLASH 0 "1" }



For 3rd person muzzle flash, read the other text file