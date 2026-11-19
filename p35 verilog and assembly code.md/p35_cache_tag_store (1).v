// P35 Cache Tag Store
// 4-line direct-mapped tag store.
// Address format: [7:4] = tag, [3:2] = index, [1:0] = byte offset.
// On an access miss, the selected line is allocated at the next rising edge.

module p35_cache_tag_store (
    input  wire       clk,
    input  wire       rst,
    input  wire       access,
    input  wire [7:0] addr,
    output wire       hit
);

    reg        valid [0:3];
    reg [3:0]  tag   [0:3];
    wire [1:0] index;
    wire [3:0] requested_tag;

    assign index         = addr[3:2];
    assign requested_tag = addr[7:4];

    // A hit is possible only during an access, when the selected line
    // is valid and its stored tag matches the requested tag.
    assign hit = access &&
                 !rst &&
                 valid[index] &&
                 (tag[index] == requested_tag);

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                valid[i] <= 1'b0;
                tag[i]   <= 4'b0000;
            end
        end
        else if (access) begin
            // Write-allocate: remember the requested tag on a miss.
            if (!(valid[index] && (tag[index] == requested_tag))) begin
                valid[index] <= 1'b1;
                tag[index]   <= requested_tag;
            end
        end
    end

endmodule
