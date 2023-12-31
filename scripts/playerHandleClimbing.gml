/// playerHandleClimbing();

var ladder = collision_line(bboxGetXCenter(), bbox_top + 2, bboxGetXCenter(), bbox_bottom, objLadder, false, false);

var ladderUp = instance_position(spriteGetXCenter(), ((bbox_top * (gravDir < 0)) + (bbox_bottom * (gravDir > 0))) - gravDir, objLadder);
var ladderDown = instance_position(spriteGetXCenter(), ((bbox_top * (gravDir < 0)) + (bbox_bottom * (gravDir > 0))) + gravDir, objLadder);

if (!playerIsLocked(PL_LOCK_CLIMB))
{
    if (((instance_exists(ladder) && gravDir == -yDir && jumpLadderCooldown <= 0)
        || (instance_exists(ladderDown) && !instance_exists(ladderUp) && gravDir == yDir && ground))
        && !climbing)
    {
        // begin climbing:
        xspeed = 0;
        
        if (isSlide)
        {
            slideLock = lockPoolRelease(slideLock);
            isSlide = false;
            mask_index = mskMegaman;
            slideTimer = 0;

            shiftObject(0, -gravDir, 0);
        }
        
        climbing = true;
        
        // implemented support for wide ladders
        if (instance_exists(ladder))
        {
            var ladderWidthHalf = abs(ladder.bbox_right-ladder.bbox_left)/2;
            shiftObject((ladder.x + ladderWidthHalf) - x, 0, true);
            if (x != ladder.x + ladderWidthHalf)
            {
                climbing = false;
            }
        }
        else
        {
            var ladderWidthHalf = abs(ladderDown.bbox_right-ladderDown.bbox_left)/2;
            // unfortunately this might still clip into a potential solid overlapping a laddertop
            shiftObject(ladderDown.x + ladderWidthHalf - x, 0, true);
            y += climbSpeed * gravDir;
            if (x != ladderDown.x + ladderWidthHalf)
            {
                climbing = false;
            }
        }
        
        if (climbing)
        {
            climbLock = lockPoolLock(PL_LOCK_MOVE,
                PL_LOCK_SLIDE,
                PL_LOCK_GRAVITY,
                PL_LOCK_TURN);
            climbLock.targetInstance = id
            climbLock.debugInfo += "<playerHandleClimbing"
            
            ground = false;
            jumpCounter = 0;
            yspeed = 0;
            ladderXScale = image_xscale;
            climbShootXscale = ladderXScale;
        }
    }
    
    if (climbing) // While climbing
    {
        if (yDir != 0 && !isShoot) // Movement
        {
            yspeed = climbSpeed * yDir;
            
            // climbing animation
            climbSpriteTimer += 1;
            if (!(climbSpriteTimer mod 8))
            {
                if (spriteX == 15)
                {
                    spriteX = 16;
                }
                else if (spriteX == 16)
                {
                    spriteX = 15;
                }
            }
        }
        else
        {
            yspeed = 0;
        }
        
        if (xDir != 0) // Left/right
        {
            climbShootXscale = xDir;
        }
        
        climbing = 1;
        
        // Getup sprite
        if (!position_meeting(x, bbox_top * (gravDir == 1) + bbox_bottom * (gravDir == -1) + 11 * gravDir, objLadder)
        // The second check is to make sure the getup animation is not shown when on the BOTTOM of a ladder that's placed in the air
        && position_meeting(x, bbox_bottom * (gravDir == 1) + bbox_top * (gravDir == -1) + gravDir, objLadder))
        {
            climbing = 2;
            if (!isShoot)
            {
                image_xscale = 1;
            }
        }
        
        // Releasing the ladder
        var jump = global.keyJumpPressed[playerID] && ((yDir != -gravDir && !jumpUpLadders) || (jumpUpLadders)) && !playerIsLocked(PL_LOCK_CLIMB);
        if ((ground && yDir == gravDir) || !place_meeting(bbox_left, y, objLadder) || !place_meeting(bbox_right, y, objLadder) || jump)
        {
            var climbedUp=false;
            if (!place_meeting(x, y, objLadder))
            {
                if (place_meeting(x, y + (gravDir * climbSpeed), objLadder))
                {   
                    playLandSound=0;
                    ground=false;  
                    climbedUp=true;
                }
            }
    
            climbing = false;
            yspeed = 0;
            isSlide = false;
            jumpCounter = !jumpUpLadders;
            climbLock = lockPoolRelease(climbLock);
            shootStandStillLock = lockPoolRelease(shootStandStillLock);
            image_xscale = ladderXScale;
            if(climbedUp)
            {
                yspeed = gravDir*climbSpeed;
                event_inherited();
            }
            else
            {
                if(jump && jumpUpLadders && yDir != gravDir)
                {
                    playerJump();
                    jumpLadderCooldown = jumpLadderCooldownMax;
                }
            }
        }
    }
}

if(!climbing)
{
    if(jumpLadderCooldown > 0)
    {
        jumpLadderCooldown--;
        if(sign(yspeed) != -gravDir || !instance_exists(ladder)) jumpLadderCooldown = 0;
    }
}
