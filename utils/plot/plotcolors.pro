function plotcolors,n,start=start,palette=palette
;+
; return N of my favorite plot colors, cycle if more than the defined colors.
; can start from aribtrary index Start.
; if palette is set, return them as old colortable number, otherwise return string 
;-


  favorite=['red',$
    'blue',$
    'Dark Green',$
    'Chocolate',$
    'Violet',$
    'Orange',$
    'Crimson',$
    'Hot Pink',$
    'Olive',$
    'Turquoise',$
    'Magenta',$
    'Lawn Green',$
    'Royal Blue']
    
  if keyword_set(palette) then begin 
    tmp=[]
    foreach c,favorite do tmp=[tmp, cgcolor(c)]
  endif            
  
  nmaxcolors=n_elements(favorite)
  
  ;cgcolors          
  ;           Active            Almond     Antique White        Aquamarine             Beige            Bisque
  ;             Black              Blue       Blue Violet             Brown         Burlywood        Cadet Blue
  ;          Charcoal        Chartreuse         Chocolate             Coral   Cornflower Blue          Cornsilk
  ;           Crimson              Cyan    Dark Goldenrod         Dark Gray        Dark Green        Dark Khaki
  ;       Dark Orchid          Dark Red       Dark Salmon   Dark Slate Blue         Deep Pink       Dodger Blue
  ;              Edge              Face         Firebrick      Forest Green             Frame              Gold
  ;         Goldenrod              Gray             Green      Green Yellow         Highlight          Honeydew
  ;          Hot Pink        Indian Red             Ivory             Khaki          Lavender        Lawn Green
  ;       Light Coral        Light Cyan        Light Gray      Light Salmon   Light Sea Green      Light Yellow
  ;        Lime Green             Linen           Magenta            Maroon       Medium Gray     Medium Orchid
  ;          Moccasin              Navy             Olive        Olive Drab            Orange        Orange Red
  ;            Orchid    Pale Goldenrod        Pale Green            Papaya              Peru              Pink
  ;              Plum       Powder Blue            Purple               Red              Rose        Rosy Brown
  ;        Royal Blue      Saddle Brown            Salmon       Sandy Brown         Sea Green          Seashell
  ;          Selected            Shadow            Sienna          Sky Blue        Slate Blue        Slate Gray
  ;              Snow      Spring Green        Steel Blue               Tan              Teal              Text
  ;           Thistle            Tomato         Turquoise            Violet        Violet Red             Wheat
  ;             White            Yellow
  ;
  
  if n_elements(start) eq 0 then start =0
  ;additional colors to fill the missing ones if needed
  if n gt n_elements(favorite) then $
    colorindices=replicate_vector(favorite[start:n_elements(favorite)-1],n) $
  else colorindices=favorite[start:start+n-1]
    ;??vector(30,250,(n-n_elements(favorite[start:(n_elements(favorite)-1)<(start+n-1)]))) $ 
  ;else colorindices=favorite[start:start+n-1]
  
  return,colorindices

end

print, plotcolors(3)

print,plotcolors(15)

end