mosaic_gg <-
function(tbl, base_family = "", 
                      ggtitle = "", 
                      xlab = "", 
                      ylab = "", 
                      fill_name = ""){
tbl_df <- tbl %>%
  as.data.frame
N <- length(levels(tbl_df[, 1]))
tbl_p_df <- tbl %>%
  prop.table %>%
  as.data.frame
tbl_p_m <- tbl_df %>%
  `[`(, 3) %>%
  tapply(tbl_df[, 2], sum) %>%
  prop.table
tbl_p_df$width <- tbl_p_m[match(tbl_p_df[, 2], names(tbl_p_m))]
tbl_p_df$height <- tbl %>%
  prop.table(margin = 2) %>%
  as.data.frame %>%
  `[`(, 3)
tbl_p_df$label_height <- unlist(tapply(tbl_p_df$height, 
                                       tbl_p_df[, 2], 
                                       function(x) x / 2 + c(0, cumsum(head(x, -1)))))
tbl_p_df$y_breaks <- unlist(tapply(tbl_p_df$height, 
                                   tbl_p_df[, 2], 
                                   cumsum))
x_center <- tbl_p_m / 2 + c(0, cumsum(head(tbl_p_m, -1)))
# x_center <- (cumsum(tbl_p_m) + c(0, head(cumsum(tbl_p_m), -1)))/2
tbl_p_df$center <- x_center[match(tbl_p_df[, 2], names(x_center))]
m1 <- ggplot(tbl_p_df, 
             aes(x = center, y = height, width = width)) + 
  geom_bar(aes(fill = tbl_df[, 1]), 
           stat = "identity", 
           col = "white", 
           size = 1, 
           position = position_stack(reverse = TRUE)) 
m2 <- m1 + 
  theme_bw(base_family = base_family)
m3 <- m2 + 
  geom_text(aes(x = center, y = 1.05), 
            label = tbl_p_df[, 2], 
            family = base_family)
m4 <- m3 + 
  geom_text(aes(x = center, y = label_height), 
            label = format(ifelse(tbl_df[, 3] == 0, "", tbl_df[, 3]), 
                           big.mark = ","), 
            position = position_identity())
x_breaks <- c(0, ifelse(cumsum(tbl_p_m) < 0.1, 0.0, cumsum(tbl_p_m)))
x_label <- format(x_breaks * 100, 
                  digits = 3, 
                  nsmall = 1)
y_breaks <- tbl_p_df$y_breaks
delta <- (max(y_breaks) - min(y_breaks)) / 20
y_breaks_sort <- sort(y_breaks)
diff(y_breaks_sort) < delta 
index <- which(diff(y_breaks_sort)  > delta)
y_breaks <- c(0, y_breaks_sort[c(index, length(y_breaks_sort))])
y_label <- format(y_breaks * 100,
                  digits = 2,
                  nsmall = 1)
m5 <- m4 + 
  scale_x_continuous(name = xlab, 
                     breaks = x_breaks, 
                     label = x_label) + 
  scale_y_continuous(name = ylab,
                     breaks = y_breaks,
                     label = y_label) + 
  scale_fill_manual(name = fill_name, 
                    values = rainbow(N)[N:1], 
                    labels = tbl_df[, 1], 
                    guide = guide_legend()) +
  ggtitle(ggtitle) +
  theme(plot.margin = unit(c(1, 2, 1, 1), "lines"))
return(m5)
}
