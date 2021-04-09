if(window.Trix) {
  const config = window.Trix.config;

  config.blockAttributes.heading1.tagName = 'h3';
  config.blockAttributes.default.tagName = 'p';
  config.blockAttributes.default.breakOnReturn = true;

  window.Trix.Block.prototype.breaksOnReturn = function() {
    const attr = this.getLastAttribute();
    const config = Trix.getBlockConfig(attr ? attr : 'default');
    return config ? config.breakOnReturn : false;
  };

  window.Trix.LineBreakInsertion.prototype.shouldInsertBlockBreak = function() {
    if(this.block.hasAttributes() && this.block.isListItem() && !this.block.isEmpty()) {
      return this.startLocation.offset > 0
    } else {
      return !this.shouldBreakFormattedBlock() ? this.breaksOnReturn : false;
    }
  };
}
