#include "edram_load_store.hlsli"

[numthreads(20, 16, 1)]
void main(uint3 xe_group_id : SV_GroupID,
          uint3 xe_group_thread_id : SV_GroupThreadID,
          uint3 xe_thread_id : SV_DispatchThreadID) {
  uint2 tile_dword_index = xe_group_thread_id.xy;
  tile_dword_index.x *= 4u;
  uint4 pixels = xe_edram_load_store_source.Load4(
      XeEDRAMOffset(xe_group_id.xy, tile_dword_index));
  // Depth.
  uint rt_offset = xe_thread_id.y * xe_edram_rt_color_depth_pitch +
                   xe_thread_id.x * 16u;
  xe_edram_load_store_dest.Store4(rt_offset, pixels >> 8u);
  // Stencil.
  uint4 stencil = (pixels & 0xFFu) << uint4(0u, 8u, 16u, 24u);
  stencil.xy |= stencil.zw;
  stencil.x |= stencil.y;
  rt_offset = xe_edram_rt_stencil_offset +
              xe_thread_id.y * xe_edram_rt_stencil_pitch + xe_thread_id.x * 4u;
  xe_edram_load_store_dest.Store(rt_offset, stencil.x);
}
