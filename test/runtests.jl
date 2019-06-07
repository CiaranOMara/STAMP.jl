using Test
using STAMP
using BioSequences
import BioGenerics

record_str = """
DE gps_test_1_m0 7.09 1 k7_c1526
1 1297 0 53 176 A
2 13 2 0 1511 T
3 5 0 1394 126 G
4 0 1171 73 282 C
5 1055 6 2 463 A
6 1281 22 201 22 A
7 1503 4 7 11 A
XX
"""

@testset "STAMP" begin
    @testset "Record" begin

        # Initialise empty record.
        record = STAMP.Record()
        @test !BioGenerics.isfilled(record)
        @test STAMP.header(record) === missing

        record = STAMP.Record(record_str)

        # Initialise from string.
        @test BioGenerics.isfilled(record)
        @test STAMP.header(record) == "gps_test_1_m0 7.09 1 k7_c1526"
        @test STAMP.frequencies(record) == [
                [1297 13 5 0 1055 1281 1503];
                [0 2 0 1171 6 22 4];
                [53 0 1394 73 2 201 7];
                [176 1511 126 282 463 22 11]
            ]
        @test STAMP.sequence(record) == dna"ATGCAAA"

        # Check negative.
        record = STAMP.Record("""
            DE test 9.59 -19 k8_c740
            1 7 76 657 0 G
            XX
            """)
        @test STAMP.header(record) == "test 9.59 -19 k8_c740"


    end # testset

    @testset "Reader" begin

        # Read from buffer.
        reader = STAMP.Reader(IOBuffer(record_str))

        record = STAMP.Record()
        @test read!(reader, record) === record
        @test STAMP.sequence(record) == dna"ATGCAAA"

        # Read from file.
        reader = STAMP.Reader(open("gps_test_1.all.PFM.txt", "r"))

        record = STAMP.Record()
        @test read!(reader, record) === record
        @test STAMP.sequence(record) == dna"ATGCAAA"
        @test STAMP.sequence(read!(reader, record)) == dna"TTGTTATG"
        @test STAMP.sequence(read!(reader, record)) == dna"CCTTTT"
        @test STAMP.sequence(read!(reader, record)) == dna"TGTTATGCA"
        @test STAMP.sequence(read!(reader, record)) == dna"AACAAAG"
        @test STAMP.sequence(read!(reader, record)) == dna"TTCTTTG"
        @test STAMP.sequence(read!(reader, record)) == dna"ACAAAAGA"
        @test STAMP.sequence(read!(reader, record)) == dna"CCCACCC"
        @test STAMP.sequence(read!(reader, record)) == dna"CCTGCT"
        @test STAMP.sequence(read!(reader, record)) == dna"CCTTCC"
        @test STAMP.sequence(read!(reader, record)) == dna"AGCAGGTGGC"
        @test STAMP.sequence(read!(reader, record)) == dna"CATTAGAATGGA"
        @test STAMP.sequence(read!(reader, record)) == dna"CCTGCTGG"
        @test STAMP.sequence(read!(reader, record)) == dna"CTGCCCCCTGCTG"

        @test_throws EOFError read!(reader, record)
    end # testset

end
