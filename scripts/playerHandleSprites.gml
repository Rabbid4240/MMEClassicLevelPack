/// playerHandleSprites(Animation Name)
if (playerIsLocked(PL_LOCK_SPRITECHANGE))
{
    exit;
}

// mega man is just a foolish 1-UP in this mode...
if (global.freeMovement)
{
    exit;
}

// setup animation variables
var AnimID;
AnimID = argument0;
lastanimation = AnimID;

animate = 0;
spriteX = 0;
spriteY = 0;

// smh Atomic Fire
//if(atomicFireHeld)
//{
    //isShoot = true;
//}

// do animations
switch (AnimID)
{
    case "Normal": // Regular animation stuff 
        // workaround to not appear as standing when being carried by beat and touching the ground
        var beat = false;
        if (instance_exists(vehicle))
        {
            if (vehicle.object_index == objBeat)
            {
                beat = true;
            }
        }
        
        animNameID = 0; // Standing
        if (isHit || isFrozen) // Hurt
        {
            animNameID = 5;
        }
        else if (climbing) // Climbing
        {
            animNameID = 4 + (climbing == 2) * 3;
        }
        else if (isSlide) // Sliding
        {
            animNameID = 6;
        }
        else if (isShocked) // MM1 Stun
        {
            animNameID = 8;
        }
        else if (ground && !beat)
        {
            if (!playerIsLocked(PL_LOCK_MOVE) || fanoutDistance != 0) && xDir != 0//Gannio: Changed so that Bass Buster does not mistakenly use a single frame. Also reflects how it should actually work (both this and the original method follow MM10-no-sidle-on-release rule).
            {
                if (stepTimer >= stepFrames) // Walking
                {
                    animNameID = 2;
                }
                else if (stepTimer > 0) // Pixel step
                {
                    animNameID = 1;
                }
            }
        }
        else // Jumping
        {
            animNameID = 3;
        }
        
        if (animNameID == 0) // Stand
        {
            blinkTimer += 1;
            blinkImage = ((blinkTimer mod blinkTimerMax + blinkDuration + 1)
                >= blinkTimerMax);
        }
        else
        {
            blinkTimer = 0;
            blinkImage = 0;
        }
        spriteY = isShoot;
        
        switch (animNameID)
        {
            case 0: // Stand 
                spriteX = blinkImage;
                break;
            case 1: // Pixel Step 
                spriteX = 2;
                break;
            case 2: // Walking 
                spriteLoopStart = 0;
                spriteLoopEnd = 3;
                spriteIDX[0] = 3;
                spriteIDX[1] = 4;
                spriteIDX[2] = 5;
                spriteIDX[3] = 6;
                spriteLoopPoint = 0;
                spriteLoopSpeed = 0.15;
                spriteX = spriteIDX[floor(spriteLoopID)];
                animate = 1;
                break;
            case 3: // Jumping 
                spriteLoopStart = 0;
                spriteLoopEnd = 3;
                spriteLoopPoint = 2;
                spriteIDX[0] = 7;
                spriteIDX[1] = 8;
                spriteIDX[2] = 9;
                spriteIDX[3] = 10;
                spriteLoopSpeed = 0.3;
                
                if (yspeed < 0) // jumping
                {
                    spriteLoopEnd = 1;
                    spriteLoopPoint = 0;
                }
                else // Falling
                {
                    spriteLoopEnd = 3;
                    spriteLoopPoint = 2;
                }
                spriteX = spriteIDX[floor(spriteLoopID)];
                animate = 1;
                
                break;
                
            case 4: // Climbing 
                spriteLoopStart = 0;
                spriteLoopEnd = 1;
                spriteIDX[0] = 15;
                spriteIDX[1] = 16;
                
                if (instance_exists(objSectionSwitcher) && !isShoot)
                {
                    climbSpriteTimer += 1;
                }
                
                spriteX = spriteIDX[!((climbSpriteTimer div 8) mod 2)];
                
                break;
                
            case 5: // Hit 
                spriteX = 13 + (!isHit) - isFrozen;
                break;
            case 6: // Sliding 
                spriteLoopStart = 0;
                spriteLoopEnd = 1;
                spriteLoopPoint = 0;
                spriteIDX[0] = 11;
                spriteIDX[1] = 12;
                spriteX = spriteIDX[floor(spriteLoopID)];
                animate = 1;
                break;
            case 7: // Climbing top 
                spriteX = 17;
                break;
            case 8: // Stun 
                spriteX = 14;
                break;
        }
        break;
    
    // - E X T R A    A N I M A T I O N    S T U F F - //
    
    // Weapons
    case "Slash":
        spriteY = 9;
        
        var initxoffset;
        
        if (climbing)
        {
            initxoffset = 8;
        }
        else if (ground)
        {
            initxoffset = 0;
        }
        else
        {
            initxoffset = 4;
        }
        
        if (instance_exists(objSlashClaw))
        {
            var sprx;
            sprx = round(instance_nearest(x, y, objSlashClaw).image_index);
            if (sprx > 3)
            {
                sprx = 3;
            }
            spriteX = initxoffset + sprx;
        }
        break;
    case "Sakugarne0":
        spriteX = 13;
        spriteY = 9;
        break;
    case "Sakugarne1":
        spriteX = 14;
        spriteY = 9;
        break;
    case "Wire":
        if (!climbing)
        {
            spriteY = 7;
            
            if (instance_exists(objWireAdapter))
            {
                if (ground || other.phase == 1)
                {
                    spriteX = 15;
                }
                else if (other.phase >= 2)
                {
                    spriteX = 16 + isShoot;
                }
            }
        }
        break;
    case "Top":
        spriteY = 8;
        spriteX = 6 + other.animFrame; // anim force
        break;
    case "Break":
        spriteY = 8;
        spriteX = other.animFrame + other.flashOffset; // anim force
        break;
    case "Cycle":
        spriteX = 10 + other.currentImg;
        spriteY = 11;
        break;
    case "Tengu1":
        spriteY = 10;
        
        var initxoffset;
        
        if (climbing)
        {
            initxoffset = 8;
        }
        else if (ground)
        {
            initxoffset = 0;
        }
        else
        {
            initxoffset = 4;
        }
        
        if (instance_exists(objTenguBlade))
        {
            var sprx;
            sprx = round(instance_nearest(x, y, objTenguBlade).image_index);
            if (sprx > 3)
            {
                sprx = 3;
            }
            spriteX = initxoffset + sprx;
        }
        break;
    case "Tengu2":
        spriteX = 12 + other.animFrame;
        spriteY = 10;
        break;
    case "Guts":
        spriteY = 6;
        break;
    case "Charge":
        spriteX = 15 + other.animFrame;
        spriteY = 10;
        break;
    
    // Other
    
    case "Talk":
        break;
    case "Teleport":
        spriteX = 10 + teleportImg;
        spriteY = 8;
        break;
    case "Spin":
        animSpinOffset += 0.125 * sign(other.image_xscale);
        
        // loop the animation
        if (animSpinOffset > 9)
        {
            animSpinOffset = 0;
        }
        if (animSpinOffset < 0)
        {
            animSpinOffset = 9;
        }
        
        spriteX = animSpinOffset;
        spriteY = 11;
        break;
    case "Bike":
        spriteX = 6 + blinkImage;
        spriteY = 12;
        break;
    case "Magnet":
        spriteY = other.spry;
        spriteX = other.sprx;
        break;
    case "Boost": // Treble Boost.
        var startup = -1;
        var aTimer = 0;//Because of how we're not overwriting blinkImage from Normal, we need TrebleBoost to handle this animation.
        with (objTrebleBoost)
        {
            startup = alarm[1];
            aTimer = animTimer;
        }
        //show_debug_message(startup);
        //printErr(startup);
        
        if (startup >= 0)
        {
            animNameID = 1;
            aTimer = 0;
            blinkImage = 0;
        }
        else
        {
            animNameID = 0; // Standing
            
            blinkImage = aTimer%2;
            //printErr(blinkImage);
            spriteX = 12+blinkImage;
            spriteY = 12+isShoot;
        }
        switch (animNameID)
        {
            case 0: // Stand 
                //spriteX = 19+blinkImage;
                /*if global.cPlayer == 1
                    {
                    if !isShoot
                        spriteY = 7;
                    }*/
                //spriteY = 2;
                break;
            case 1:
            spriteX = 12;
            spriteY = 13;
            if (startup >= 9)
            {
                spriteX += 2;
                //spriteY++;
            }
            else if (startup >= 6)
            {
                spriteX += 3;
                //spriteY++;
            }
            else
            {
                spriteX += 4;
                //spriteY++;
            }
            /*switch (floor(startup/4))
            {
                //case 3:
                
                
                
                case 2:
                    spriteX += 2;
                    spriteY++;
                break;
                
                case 1:
                    spriteX += 3;
                    spriteY++;
                break;
                
                case 0:
                    spriteX += 4;
                    spriteY++;
                break;
            
            }*/
                
                
            break;
        }
        
        break;
    
    case "Marine": // Rush Marine
        var startup = -1;
        var aTimer = 0; // Because of how we're not overwriting blinkImage from Normal, we need TrebleBoost to handle this animation.
        var onLand = false;
        if (instance_exists(myRushMarine))
        {
            with (myRushMarine)
            {
                startup = alarm[1];
                aTimer = animTimer;
                onLand = !moveLock || !other.inWater;
            }
        }
        
        if (startup >= 0)
        {
            animNameID = 1;
            aTimer = 0;
            blinkImage = 0;
        }
        else
        {
            animNameID = 0; // Standing
            
            blinkImage = aTimer%2;
            spriteX = 4 + blinkImage + 2 * isShoot + 4 * onLand;
            spriteY = 13;
        }
        
        switch (animNameID)
        {
            // moving
            case 0: 
                break;
            
            // startup animation
            case 1:
                spriteX = 1;
                spriteY = 13;
                if (startup >= 9)
                {
                    spriteX += 0;
                }
                else if (startup >= 6)
                {
                    spriteX += 1;
                }
                else
                {
                    spriteX += 2;
                }
                
                break;
        }
        
        break;
}

if (animate) // Animation
{
    if (spriteLoopID < spriteLoopEnd + 1)
    {
        spriteLoopID += spriteLoopSpeed;
    }
    if (spriteLoopID >= spriteLoopEnd + 1)
    {
        spriteLoopID = spriteLoopPoint;
    }
}
else // reset animation
{
    spriteLoopID = 0;
}

/*
0 = stand
1 = side step
2 = walk
3 = jump
4 = climb
5 = hurt
6 = slide
7 = climbTop
8 = shocked/mm1 stun
*/
