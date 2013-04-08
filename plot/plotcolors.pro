function plotcolors,n,start=start
;return n of my favorite plot colors, cycle if more than the defined colors

favorite=[cgcolor('red'),$
          cgcolor('blue'),$
          cgcolor('Dark Green'),$
          cgcolor('Chocolate'),$
          cgcolor('Violet'),$
          cgcolor('Orange'),$
          cgcolor('Crimson'),$
          cgcolor('Hot Pink'),$
          cgcolor('Olive'),$
          cgcolor('Turquoise'),$
          cgcolor('Magenta'),$
          cgcolor('Lawn Green'),$
          cgcolor('Royal Blue')]
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