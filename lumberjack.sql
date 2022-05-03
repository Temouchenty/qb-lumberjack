CREATE TABLE IF NOT EXISTS `lumberjack` (
  `citizenid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `level` int(11) DEFAULT 1,
  `action` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin ROW_FORMAT=DYNAMIC;