-- easing

ease = {i={},o={},io={}}

function ease.i.quad(x)
 return x*x
end

function ease.i.cubic(x)
 return x^3
end

function ease.i.quart(x)
 return x^4
end

function ease.i.quint(x)
 return x^5
end

function ease.i.expo(x)
 return x == 0 and 0 or 2^((x-1)*10)
end

function ease.i.circ(x)
 return 1-sqrt(1-x*x)
end

function ease.i.back(x)
 local c1 = 1.70158
 local c3 = c1 + 1

 return c3*x^3 - c1*x^2
end

function ease.i.elastic(x)
 local c = 1 / 3

 return x == 0 and 0 or
       (x==1 and 1 or
        -2^((x-1)*10) * -sin((x * 10 - 10.75) * c))
end

-- defined relative to f
_bounce_y0 = {0,0.75,0.9375,0.984375}
_bounce_x0 = {0,1.5,2.25,2.625}
function ease.i.bounce(x)
 local a = 7.5625
 local f = 2.75
 local x0,y0=_bounce_x0,_bounce_y0
 local i = 4
 if (x < 1 / f) then
  i=1
 elseif (x < 2 / f) then
  i=2
 elseif (x < 2.5 / f) then
  i=3
 end
 return a*(x-x0[i]/f)^2 + y0[i]
end

function join(f1,f2,x1)
 x1 = x1 or .5
 return function(x)
  if x < x1 then
   return f1(x/x1)/2
  else
   return .5+f2((x-x1)/(1-x1))/2
  end
 end
end

for name, fn in pairs(ease.i) do
 ease.o[name] = function(x)
  return 1 - fn(1-x)
 end
end
ease.o.bounce, ease.i.bounce =
  ease.i.bounce, ease.o.bounce

for name, fn in pairs(ease.i) do
 ease.io[name] =
  join(fn, ease.o[name])
end

function tween(t, ease,
  x0, x1, finish)
 t = flr(t*30)-1
 ease = ease or easelinear
 x0 = x0 or 0
 x1 = x1 or 1
 return cocreate(function()
  local i,d,finished=0,1,false
  local v
  while true do
   if i <0 or i > t then
    finished=true
   end
   v = i/t
   yield({x0 + (x1-x0) * ease(v),
          v,
          finished})
   i+=d
   if i <0 or i > t then
    if finish=="reflect" then
     d=-d
     i+=d
    elseif finish=="wrap" then
     i=0
    else
     i=t
    end
   end
  end
 end)
end

function animate(t, ease,
  x0, x1, fn, finish)
 return cocreate(function()
  local t = tween(t,ease,x0,x1,finish)
  local alive, v = coresume(t)
  while alive do
   fn(v[1])
   yield()
   alive, v = coresume(t)
  end
 end)
end
