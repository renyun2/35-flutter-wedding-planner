function parseLayout(layoutJson) {
  try {
    const parsed = JSON.parse(layoutJson || '[]');
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function validateSeating(layout, guestCount) {
  const tables = parseLayout(layout);
  const totalCapacity = tables.reduce((sum, t) => sum + (Number(t.capacity) || 0), 0);
  const assignedGuests = tables.reduce((sum, t) => sum + (Array.isArray(t.guest_ids) ? t.guest_ids.length : 0), 0);

  if (totalCapacity < guestCount) {
    return {
      valid: false,
      error: `桌位总容量 ${totalCapacity} 小于宾客数 ${guestCount}`,
      total_capacity: totalCapacity,
      guest_count: guestCount,
    };
  }

  if (assignedGuests > totalCapacity) {
    return {
      valid: false,
      error: '已分配宾客超过桌位容量',
      total_capacity: totalCapacity,
      assigned: assignedGuests,
    };
  }

  return {
    valid: true,
    total_capacity: totalCapacity,
    guest_count: guestCount,
    assigned: assignedGuests,
  };
}

module.exports = { parseLayout, validateSeating };
