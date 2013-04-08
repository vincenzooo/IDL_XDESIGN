pro writeTif, tiffile
    image=transpose(reverse(transpose(tvrd(true=1))))
    write_tiff,tiffile,image
end