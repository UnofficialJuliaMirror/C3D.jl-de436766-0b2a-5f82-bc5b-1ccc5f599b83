@testset "Sample 02 tests" begin
    dec_real = readc3d(joinpath(datadir, "sample02", "Dec_real.c3d"))
    dec_int = readc3d(joinpath(datadir, "sample02", "DEC_INT.C3D"))

    sgi_real = readc3d(joinpath(datadir, "sample02", "sgi_real.c3d"))
    sgi_int = readc3d(joinpath(datadir, "sample02", "sgi_int.c3d"))

    pc_real = readc3d(joinpath(datadir, "sample02", "pc_real.c3d"))
    pc_int = readc3d(joinpath(datadir, "sample02", "pc_int.c3d"))

    @testset "Parameters equivalency between file types" begin
        for file in [ dec_real, dec_int, sgi_real, sgi_int, pc_int ]
            @testset "Ensure group-set equivalency between pc_real and $(file.name)" begin
                @test isempty(setdiff(keys(pc_real.groups), keys(file.groups)))
            end
            for grp in keys(pc_real.groups)
                @testset "Ensure parameter-set equivalency of group :$(pc_real.groups[grp].symname) between pc_real and $(file.name)" begin
                    @test isempty(setdiff(keys(pc_real.groups[grp].p), keys(file.groups[grp].p)))
                end
                @testset "Are the :$(pc_real.groups[grp].symname) parameters approximately equal?" begin
                    for param in keys(pc_real.groups[grp].p)
                        if eltype(pc_real.groups[grp][param]) <: Number
                            if grp == :POINT && param == :SCALE
                                @test abs.(pc_real.groups[grp][param]) ≈ abs.(file.groups[grp][param])
                            else
                                @test pc_real.groups[grp][param] ≈ file.groups[grp][param]
                            end
                        else
                          @test reduce(*,pc_real.groups[grp][param] .== file.groups[grp][param])
                        end
                    end
                end
            end
        end
    end

    @testset "Data equivalency between file types" begin
        for file in [ dec_real, dec_int, sgi_real, sgi_int, pc_int ]
            @testset "Ensure data equivalency between pc_real and $(file.name)" begin
                for sig in keys(pc_real.point)
                  @test haskey(file.point,sig)
                  @test pc_real.point[sig] ≈ file.point[sig]
                end
                for sig in keys(pc_real.analog)
                  @test haskey(file.analog,sig)
                  @test pc_real.analog[sig] ≈ file.analog[sig]
                end
            end
        end
    end
end
