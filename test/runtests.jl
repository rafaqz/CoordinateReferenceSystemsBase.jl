using GeoFormatTypes, Test
using GeoFormatTypes: Geom, CRS, Extended, Unknown

@testset "Test construcors" begin
    @test_throws ArgumentError ProjString("+lat_ts=56.5 +ellps=GRS80")
    @test_throws ArgumentError ProjJSON(Dict("fype" => 1))
    @test_throws ArgumentError ProjJSON("fype")
    @test_throws ArgumentError EPSG("ERROR:4326")
    @test EPSG("EPSG:4326") == EPSG(4326)
    @test EPSG("EPSG:4326+3855") == EPSG((4326, 3855))
end

@testset "Test constructors" begin
    @test ProjString("+proj=test") isa ProjString
    @test ProjJSON(Dict("type" => "GeographicCRS")) isa ProjJSON
    @test ProjJSON("type: GeographicCRS") isa ProjJSON
    @test EPSG(4326) isa EPSG
    @test EPSG(Int16(4326)) isa EPSG
    @test EPSG((4326, 3855)) isa EPSG
    @test WellKnownText("test") isa WellKnownText{Unknown}
    @test WellKnownBinary([1, 2, 3, 4]) isa WellKnownBinary{Unknown}
    @test WellKnownText2("test") isa WellKnownText2{Unknown}
    @test ESRIWellKnownText("test") isa ESRIWellKnownText{Unknown}
    @test WellKnownText(Extended(), "test") isa WellKnownText{Extended}
    @test WellKnownBinary(Extended(), [1, 2, 3, 4]) isa WellKnownBinary{Extended}
    @test WellKnownText2(CRS(), "test") isa WellKnownText2{CRS}
    @test ESRIWellKnownText(Geom(), "test") isa ESRIWellKnownText{Geom}
    @test GML("test") isa GML{Unknown}
    @test GML(Geom(), "test") isa GML{Geom}
    @test GML(CRS(), "test") isa GML{CRS} # Probably doesn't actually exist
    @test KML("test") isa KML
    @test GeoJSON("test") isa GeoJSON
end

@testset "Test conversion to string or int" begin
    @test convert(String, ProjString("+proj=test")) == "+proj=test"
    @test convert(String, EPSG(4326)) == "EPSG:4326"
    @test convert(Int64, EPSG(4326)) == 4326
    @test convert(Int32, EPSG(4326)) == Int32(4326)
    @test_throws MethodError convert(Int, EPSG(4326, 3855))
    @test convert(String, EPSG(4326, 3855)) == "EPSG:4326+3855"
    @test convert(String, WellKnownText("test")) == "test"
    @test convert(String, WellKnownText2("test")) == "test"
    @test convert(String, ESRIWellKnownText("test")) == "test"
    @test convert(String, GML("test")) == "test"
    @test convert(String, KML("test")) == "test"
    @test convert(String, GeoJSON("test")) == "test"
end

@testset "Test val" begin
    @test GeoFormatTypes.val(EPSG(4326)) == 4326
    @test GeoFormatTypes.val(EPSG(4326, 3855)) == (4326, 3855)
end

@testset "Equality" begin
    @test ProjString("+proj=test") == ProjString("+proj=test")
    @test ProjJSON(Dict("type" => "GeographicCRS")) == ProjJSON(Dict("type" => "GeographicCRS"))
    @test ProjJSON("type: GeographicCRS") == ProjJSON("type: GeographicCRS")
    @test EPSG(4326) == EPSG(4326)
    @test EPSG(4326) != EPSG(3855)
    @test EPSG(4326) != EPSG(4326, 3855)
    @test EPSG(4326) != EPSG(3855, 4326)
    @test EPSG(4326, 3855) == EPSG(4326, 3855)
    @test WellKnownText("test") == WellKnownText("test")
    @test WellKnownBinary([1, 2, 3, 4]) == WellKnownBinary([1, 2, 3, 4])
    @test WellKnownText2("test") == WellKnownText2("test")
    @test ESRIWellKnownText("test") == ESRIWellKnownText("test")
    @test WellKnownText(Extended(), "test") == WellKnownText(Extended(), "test")
    @test WellKnownBinary(Extended(), [1, 2, 3, 4]) == WellKnownBinary(Extended(), [1, 2, 3, 4])
    @test WellKnownText2(CRS(), "test") == WellKnownText2(CRS(), "test")
    @test ESRIWellKnownText(Geom(), "test") == ESRIWellKnownText(Geom(), "test")
    @test GML("test") == GML("test")
    @test GML(Geom(), "test") == GML(Geom(), "test")
    @test GML(CRS(), "test") == GML(CRS(), "test")
    @test KML("test") == KML("test")
    @test GeoJSON("test") == GeoJSON("test")
end

# `convert` placeholder methods
Base.convert(target::Type{<:GeoFormat}, mode::Union{Geom,Type{Geom}}, source::GeoFormat; kwargs...) =
    (:geom, kwargs...)
Base.convert(target::Type{<:GeoFormat}, mode::Union{CRS,Type{CRS}}, source::GeoFormat; kwargs...) =
    (:crs, kwargs...)

@testset "Test convert mode allocation" begin
    @testset "Test identical type is passed through unchanged" begin
        @test convert(WellKnownText, WellKnownText(Extended(), "test")) == WellKnownText(Extended(), "test")
        @test convert(ProjString, ProjString("+proj=test")) == ProjString("+proj=test")
    end
    @testset "Test conversions are assigned to crs or geom correctly" begin
        @test convert(WellKnownText, WellKnownText2(CRS(), "test")) == (:crs,)
        @test convert(WellKnownText2, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(WellKnownBinary, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(ProjString, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(EPSG, ProjString("+proj=test")) == (:crs,)
        @test convert(CoordSys, ProjString("+proj=test")) == (:crs,)

        @test convert(GeoJSON, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(KML, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(GML, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(ESRIWellKnownText, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownBinary, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText, WellKnownText2(Geom(), "test")) == (:geom,)

        @test convert(GeoJSON, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(KML, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(GML, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(ESRIWellKnownText, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(WellKnownBinary, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Extended(), "test")) == (:geom,)
        @test convert(WellKnownText, WellKnownText2(Extended(), "test")) == (:geom,)

        @test convert(GeoJSON, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(KML, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(GML, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(ESRIWellKnownText, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(WellKnownBinary, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Unknown(), "test")) == (:geom,)
        @test convert(WellKnownText, WellKnownText2(Unknown(), "test")) == (:geom,)
    end
    @testset "Test kargs pass through convert" begin
        @test convert(WellKnownText, WellKnownText2(CRS(), "test"); order=:trad) == (:crs, :order => :trad,)
        @test convert(GML, WellKnownText(Extended(), "test"); order=:custom) == (:geom, :order => :custom)
    end
    @testset "Test conversions that are not possible throw an error" begin
        @test_throws ArgumentError convert(KML, ProjString("+proj=test"))
        @test_throws ArgumentError convert(GeoJSON, ProjString("+proj=test"))
        @test_throws ArgumentError convert(ProjString, WellKnownText(Geom(), "test"))
        @test_throws ArgumentError convert(CoordSys, WellKnownText(Geom(), "test"))
        @test_throws ArgumentError convert(EPSG, WellKnownText(Geom(), "test"))
    end
    @testset "Display methods" begin
        buf = IOBuffer()
        cbuf = IOContext(buf, :compact => true)

        for (obj, (cstr, str)) in [
            (ProjString("+proj=test"), ("ProjString", "ProjString: +proj=test")),
            (ProjJSON(Dict("type" => "GeographicCRS")), ("ProjJSON", "ProjJSON: Dict(\"type\" => \"GeographicCRS\")")),
            (ProjJSON("type: GeographicCRS"), ("ProjJSON", "ProjJSON: type: GeographicCRS")),
            (EPSG(4326), ("EPSG", "EPSG:4326")),
            (EPSG((4326, 3855)), ("EPSG", "EPSG:4326+3855")),
            (WellKnownText("test"), ("WellKnownText", "WellKnownText with Unknown mode: test")),
            (WellKnownBinary([1, 2, 3, 4]), ("WellKnownBinary", "WellKnownBinary with Unknown mode: [1, 2, 3, 4]")),
            (WellKnownText2("test"), ("WellKnownText2", "WellKnownText2 with Unknown mode: test")),
            (ESRIWellKnownText("test"), ("ESRIWellKnownText", "ESRIWellKnownText with Unknown mode: test")),
            (WellKnownText(Extended(), "test"), ("WellKnownText", "WellKnownText with Extended mode: test")),
            (WellKnownBinary(Extended(), [1, 2, 3, 4]), ("WellKnownBinary", "WellKnownBinary with Extended mode: [1, 2, 3, 4]")),
            (WellKnownText2(CRS(), "test"), ("WellKnownText2", "WellKnownText2 with CRS mode: test")),
            (ESRIWellKnownText(Geom(), "test"), ("ESRIWellKnownText", "ESRIWellKnownText with Geometry mode: test")),
            (GML("test"), ("GML", "GML with Unknown mode: test")),
            (GML(Geom(), "test"), ("GML", "GML with Geometry mode: test")),
            (GML(CRS(), "test"), ("GML", "GML with CRS mode: test")),
            (KML("test"), ("KML", "KML: test")),
            (GeoJSON("test"), ("GeoJSON String", "GeoJSON String: test")),
        ]

            show(cbuf, MIME"text/plain"(), obj)
            @test cstr == String(take!(buf))
            show(buf, MIME"text/plain"(), obj)
            @test str == String(take!(buf))

        end
    end
end
