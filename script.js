document.addEventListener('DOMContentLoaded', () => {
  // 1. Geração Dinâmica do Menu Lateral a partir das seções de tabelas
  const tableSections = document.querySelectorAll('.table-section');
  const sidebarMenu = document.getElementById('sidebarMenu');
  const tableCountBadge = document.getElementById('tableCountBadge');

  tableCountBadge.textContent = tableSections.length;

  tableSections.forEach((section) => {
    const tableId = section.id;
    const li = document.createElement('li');
    const link = document.createElement('a');
    link.href = `#${tableId}`;
    link.innerHTML = `<span>${tableId}</span><i class="fas fa-chevron-right"></i>`;

    link.addEventListener('click', () => {
      document.querySelectorAll('.sidebar-menu a').forEach((el) => el.classList.remove('active'));
      link.classList.add('active');
      if (window.innerWidth <= 920) {
        document.getElementById('sidebar').classList.remove('open');
      }
    });

    li.appendChild(link);
    sidebarMenu.appendChild(li);
  });

  // 2. Toggle Responsivo da Sidebar em Dispositivos Móveis
  const sidebarToggle = document.getElementById('sidebarToggle');
  const sidebar = document.getElementById('sidebar');

  if (sidebarToggle) {
    sidebarToggle.addEventListener('click', () => {
      sidebar.classList.toggle('open');
    });
  }

  // 3. Alternância Light / Dark Mode com Persistência
  const themeToggle = document.getElementById('themeToggle');
  const themeIcon = document.getElementById('themeIcon');
  const themeLabel = document.getElementById('themeLabel');

  const savedTheme = localStorage.getItem('amplex_dict_theme');
  if (savedTheme === 'dark') {
    document.body.classList.add('dark-mode');
    themeIcon.className = 'fas fa-sun';
    themeLabel.textContent = 'Modo Claro';
  }

  themeToggle.addEventListener('click', () => {
    const isDark = document.body.classList.toggle('dark-mode');
    localStorage.setItem('amplex_dict_theme', isDark ? 'dark' : 'light');
    themeIcon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
    themeLabel.textContent = isDark ? 'Modo Claro' : 'Modo Escuro';
  });

  // 4. Filtro em Tempo Real (Tabelas e Atributos)
  const searchInput = document.getElementById('searchInput');
  const clearSearchBtn = document.getElementById('clearSearchBtn');
  const filterStatus = document.getElementById('filterStatus');

  function applyFilter() {
    const query = searchInput.value.trim().toLowerCase();
    clearSearchBtn.hidden = query.length === 0;

    let visibleTables = 0;
    let visibleRows = 0;

    tableSections.forEach((section) => {
      const tableName = section.dataset.tableName.toLowerCase();
      const tableMatches = tableName.includes(query);
      const rows = section.querySelectorAll('tbody tr');
      let sectionHasVisibleRow = false;

      rows.forEach((row) => {
        const rowText = row.textContent.toLowerCase();
        if (query === '' || tableMatches || rowText.includes(query)) {
          row.style.display = '';
          sectionHasVisibleRow = true;
          visibleRows++;
        } else {
          row.style.display = 'none';
        }
      });

      if (sectionHasVisibleRow) {
        section.style.display = '';
        visibleTables++;
      } else {
        section.style.display = 'none';
      }
    });

    if (query === '') {
      filterStatus.hidden = true;
    } else {
      filterStatus.hidden = false;
      filterStatus.textContent = `Filtro ativo para "${searchInput.value}": ${visibleTables} entidade(s) e ${visibleRows} atributo(s) encontrado(s).`;
    }
  }

  searchInput.addEventListener('input', applyFilter);

  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    applyFilter();
    searchInput.focus();
  });

  // 5. Modal do DER com zoom e navegação por arraste
  const derModal = document.getElementById('derModal');
  const openDerModalBtn = document.getElementById('openDerModalBtn');
  const closeDerModalBtn = document.getElementById('closeDerModalBtn');
  const panzoomElem = document.getElementById('panzoomContainer');
  const derViewport = document.getElementById('derViewport');
  const zoomInBtn = document.getElementById('zoomInBtn');
  const zoomOutBtn = document.getElementById('zoomOutBtn');
  const zoomResetBtn = document.getElementById('zoomResetBtn');

  let derScale = 1;
  let derTranslateX = 0;
  let derTranslateY = 0;
  let isDraggingDer = false;
  let dragStartX = 0;
  let dragStartY = 0;
  let dragOriginX = 0;
  let dragOriginY = 0;

  function applyDerTransform() {
    panzoomElem.style.transform = `translate(${derTranslateX}px, ${derTranslateY}px) scale(${derScale})`;
  }

  function setDerScale(nextScale, clientX, clientY) {
    const boundedScale = Math.min(5, Math.max(0.5, nextScale));

    if (clientX !== undefined && clientY !== undefined && boundedScale !== derScale) {
      const bounds = derViewport.getBoundingClientRect();
      const pointerX = clientX - (bounds.left + bounds.width / 2);
      const pointerY = clientY - (bounds.top + bounds.height / 2);
      const ratio = boundedScale / derScale;
      derTranslateX = pointerX - (pointerX - derTranslateX) * ratio;
      derTranslateY = pointerY - (pointerY - derTranslateY) * ratio;
    }

    derScale = boundedScale;
    applyDerTransform();
  }

  openDerModalBtn.addEventListener('click', () => {
    derModal.classList.add('open');
    derScale = 1;
    derTranslateX = 0;
    derTranslateY = 0;
    applyDerTransform();
  });

  closeDerModalBtn.addEventListener('click', () => {
    derModal.classList.remove('open');
  });

  zoomInBtn.addEventListener('click', () => {
    setDerScale(derScale * 1.2);
  });

  zoomOutBtn.addEventListener('click', () => {
    setDerScale(derScale / 1.2);
  });

  zoomResetBtn.addEventListener('click', () => {
    derScale = 1;
    derTranslateX = 0;
    derTranslateY = 0;
    applyDerTransform();
  });

  derViewport.addEventListener('wheel', (event) => {
    event.preventDefault();
    const factor = event.deltaY < 0 ? 1.1 : 1 / 1.1;
    setDerScale(derScale * factor, event.clientX, event.clientY);
  }, { passive: false });

  panzoomElem.addEventListener('pointerdown', (event) => {
    if (event.button !== 0) return;

    isDraggingDer = true;
    dragStartX = event.clientX;
    dragStartY = event.clientY;
    dragOriginX = derTranslateX;
    dragOriginY = derTranslateY;
    panzoomElem.setPointerCapture(event.pointerId);
  });

  panzoomElem.addEventListener('pointermove', (event) => {
    if (!isDraggingDer) return;

    derTranslateX = dragOriginX + event.clientX - dragStartX;
    derTranslateY = dragOriginY + event.clientY - dragStartY;
    applyDerTransform();
  });

  function stopDraggingDer(event) {
    if (!isDraggingDer) return;

    isDraggingDer = false;
    if (panzoomElem.hasPointerCapture(event.pointerId)) {
      panzoomElem.releasePointerCapture(event.pointerId);
    }
  }

  panzoomElem.addEventListener('pointerup', stopDraggingDer);
  panzoomElem.addEventListener('pointercancel', stopDraggingDer);
  panzoomElem.addEventListener('lostpointercapture', () => {
    isDraggingDer = false;
  });

  // 6. Modal do Script DDL com Syntax Highlighting e Cópia
  const ddlModal = document.getElementById('ddlModal');
  const openDdlModalBtn = document.getElementById('openDdlModalBtn');
  const closeDdlModalBtn = document.getElementById('closeDdlModalBtn');
  const copyDdlBtn = document.getElementById('copyDdlBtn');
  const ddlCodeBlock = document.getElementById('ddlCodeBlock');

  openDdlModalBtn.addEventListener('click', () => {
    ddlModal.classList.add('open');
    if (typeof Prism !== 'undefined') {
      Prism.highlightElement(ddlCodeBlock);
    }
  });

  closeDdlModalBtn.addEventListener('click', () => {
    ddlModal.classList.remove('open');
  });

  copyDdlBtn.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(ddlCodeBlock.textContent);
      const originalHtml = copyDdlBtn.innerHTML;
      copyDdlBtn.innerHTML = '<i class="fas fa-check"></i> Copiado!';
      setTimeout(() => {
        copyDdlBtn.innerHTML = originalHtml;
      }, 2200);
    } catch (err) {
      alert('Não foi possível copiar automaticamente. Selecione o código e pressione Ctrl+C.');
    }
  });

  // Fechar modais ao clicar fora do conteúdo ou pressionar ESC
  window.addEventListener('click', (e) => {
    if (e.target === derModal) derModal.classList.remove('open');
    if (e.target === ddlModal) ddlModal.classList.remove('open');
  });

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      derModal.classList.remove('open');
      ddlModal.classList.remove('open');
    }
  });
});