export const HOME_STATUS_ENTITIES = [
  "input_boolean.anwesend",
  "sensor.heizung_sollprofil",
  "sensor.rollladen_open_ts",
  "sensor.rollladen_close_ts",
  "sensor.saros_20_set_status",
  "sensor.hamburg_fu_wetterzustand",
  "sensor.eaton_3s850d_batterie_ladung",
];

export const ROOMS_CONFIG = {
  title: "Raeume",
  description:
    "Kompakte Klima- und Umgebungsansicht fuer die heutigen Wohnraeume. Manuelle Alltagsbedienung bleibt bewusst im Modul Wohnen.",
  default_room_id: "kuche",
  rooms: [
    {
      id: "kuche",
      title: "Kueche",
      icon: "mdi:fridge-outline",
      caption: "Klima, Balkonzugang und Rolllaeden",
      summary_entities: [
        "sensor.kuche_wandthermostat_temperatur",
        "sensor.kuche_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.kuche_wandthermostat", name: "Thermostat" },
        { entity: "binary_sensor.kuche_balkon_turkontakt", name: "Balkontuer" },
        { entity: "cover.kuche_balkon_rollo", name: "Balkonrollo" },
        { entity: "cover.kuche_sieker_rollo", name: "Fensterrollo" },
      ],
    },
    {
      id: "wohnzimmer",
      title: "Wohnzimmer",
      icon: "mdi:sofa-outline",
      caption: "Klima und Zugang",
      summary_entities: [
        "sensor.wohnzimmer_wandthermostat_temperatur",
        "sensor.wohnzimmer_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.wohnzimmer_wandthermostat", name: "Thermostat" },
        { entity: "binary_sensor.wohnzimmer_turkontakt", name: "Tuersensor" },
      ],
    },
    {
      id: "schlafzimmer",
      title: "Schlafzimmer",
      icon: "mdi:bed-king-outline",
      caption: "Klima, Rollo und Lichtsensor",
      summary_entities: [
        "sensor.schlazi_wandthermostat_temperatur",
        "sensor.schlazi_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.schlazi_wandthermostat", name: "Thermostat" },
        { entity: "cover.schlazi_rollo", name: "Rollo" },
        { entity: "sensor.lichtsensor_schlafzimmer_illuminance", name: "Lichtsensor" },
      ],
    },
    {
      id: "bad",
      title: "Bad",
      icon: "mdi:bathtub-outline",
      caption: "Klima",
      summary_entities: [
        "sensor.bad_wandthermostat_temperatur",
        "sensor.bad_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.bad_wandthermostat", name: "Thermostat" },
      ],
    },
    {
      id: "flur",
      title: "Flur",
      icon: "mdi:door-open",
      caption: "Klima",
      summary_entities: [
        "sensor.flur_wandthermostat_temperatur",
        "sensor.flur_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.flur_wandthermostat", name: "Thermostat" },
      ],
    },
    {
      id: "gaestebad",
      title: "Gaestebad",
      icon: "mdi:shower",
      caption: "Klima, Zusatzsensor und Rollo",
      summary_entities: [
        "sensor.gastebad_wandthermostat_temperatur",
        "sensor.gastebad_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.gastebad_wandthermostat", name: "Thermostat" },
        { entity: "cover.gaste_bad_rollo", name: "Rollo" },
        { entity: "sensor.0xa4c1384490e4e5ea_temperature", name: "Zusatzsensor Temp" },
        { entity: "sensor.0xa4c1384490e4e5ea_humidity", name: "Zusatzsensor Feuchte" },
      ],
    },
    {
      id: "gaestezimmer",
      title: "Gaestezimmer",
      icon: "mdi:account-outline",
      caption: "Klima, Fenster und Rolllaeden",
      summary_entities: [
        "sensor.gaste_wandthermostat_temperatur",
        "sensor.gaste_wandthermostat_luftfeuchtigkeit",
      ],
      detail_entities: [
        { entity: "climate.gaste_wandthermostat", name: "Thermostat" },
        { entity: "binary_sensor.gaste_fenster_kontakt", name: "Fensterkontakt" },
        { entity: "cover.gaste_heck_rollo", name: "Heckrollo" },
        { entity: "cover.gaste_sieker_rollo", name: "Siekerrollo" },
      ],
    },
    {
      id: "balkon",
      title: "Balkon",
      icon: "mdi:weather-partly-cloudy",
      caption: "Aussenklima und Licht",
      summary_entities: [
        "sensor.0x00158d008b61ad80_temperature",
        "sensor.0x00158d008b61ad80_humidity",
        "sensor.balkon_lichtsensor_durchschnittliche_beleuchtungsstarke",
      ],
      detail_entities: [
        { entity: "sensor.0x00158d008b61ad80_temperature", name: "Temperatur" },
        { entity: "sensor.0x00158d008b61ad80_humidity", name: "Luftfeuchte" },
        { entity: "sensor.0x00158d008b61ad80_pressure", name: "Luftdruck" },
        { entity: "sensor.balkon_lichtsensor_beleuchtungsstarke", name: "Lux aktuell" },
      ],
    },
  ],
  environment_panel: {
    title: "Zugang und Umgebung",
    description: "Operator-relevante Kontakte und Aussenwerte bleiben separat sichtbar.",
    entities: [
      { entity: "binary_sensor.kuche_balkon_turkontakt", name: "Balkontuer" },
      {
        entity: "sensor.balkon_lichtsensor_durchschnittliche_beleuchtungsstarke",
        name: "Balkon Lux (Durchschnitt)",
      },
    ],
  },
};

export const MODULES = [
  {
    id: "heating",
    title: "Heizung",
    icon: "mdi:radiator",
    description:
      "Erste echte MVP-Vertikale mit kuratierten Safe-Aktionen, Diagnose und Tuning.",
    summary_entities: [
      "sensor.heizung_sollprofil",
      "input_select.heizung_aktives_profil",
      "input_boolean.heizung_override",
      "input_datetime.heizung_last_applied",
    ],
    status_entities: [
      "input_boolean.heizung_automatik",
      "input_boolean.heizung_urlaub",
      "binary_sensor.anwesend_stabil",
      "binary_sensor.winterbetrieb_empfohlen",
      "sensor.hamburg_fu_temp_next12h_max",
    ],
    safe_actions: [
      {
        label: "Sollprofil anwenden",
        service: "script.heizung_profil_anwenden_pkg",
        style: "primary",
      },
    ],
    diagnostic_entities: [
      {
        entity: "sensor.heizung_sollprofil",
        attributes: [
          "grund",
          "decision_chain",
          "automatik_enabled",
          "last_profile",
          "last_applied_local",
          "last_scene",
          "last_action_text",
        ],
      },
      {
        entity: "input_text.heizung_last_action",
      },
      {
        entity: "input_text.heizung_last_scene",
      },
    ],
    tuning_entities: [
      "input_number.heizung_abwesenheit_stunden",
      "input_number.heizung_temperatur_sommer",
      "input_boolean.heizung_debug",
    ],
    service_entities: [
      "timer.heizung_override",
      "input_boolean.heizung_override",
    ],
    legacy_note:
      "Das bestehende Hub-Fachmodul in dashboards/sieker_hub.yaml bleibt bis zur spaeteren Migration der Referenzpfad.",
  },
  {
    id: "shutters",
    title: "Rolllaeden",
    icon: "mdi:window-shutter",
    description:
      "Kuratiertes Fachmodul mit Fokus auf Automatikstatus, Debug-Sensoren und Apply-Skripte.",
    summary_entities: [
      "input_boolean.rollladen_automation_enabled",
      "sensor.rollladen_open_ts",
      "sensor.rollladen_close_ts",
    ],
    status_entities: [
      "binary_sensor.rollladen_day_window",
      "input_boolean.rollladen_override_ost",
      "input_boolean.rollladen_override_west",
      "input_boolean.beschattung_ost",
      "input_boolean.beschattung_west",
    ],
    safe_actions: [
      {
        label: "Ost anwenden",
        service: "script.rollladen_ost_apply",
      },
      {
        label: "West anwenden",
        service: "script.rollladen_apply_west",
      },
      {
        label: "Nord anwenden",
        service: "script.rollladen_apply_nord",
      },
    ],
    diagnostic_entities: [
      { entity: "sensor.rollladen_ost_debug" },
      { entity: "sensor.rollladen_west_debug" },
      { entity: "sensor.rollladen_nord_debug" },
    ],
    tuning_entities: [
      "input_number.rollladen_offset_morgen_min",
      "input_number.rollladen_offset_abend_min",
      "input_datetime.rollladen_latest_close",
    ],
    legacy_note:
      "Beschattung, Diagnose und Service bleiben vorerst im bestehenden YAML-Fachmodul.",
  },
  {
    id: "roborock",
    title: "Roborock",
    icon: "mdi:robot-vacuum",
    description:
      "MVP-Bridge auf sichere Programmstarts und Diagnose. Karte, Wartung und Wochenplan bleiben noch im YAML-Dashboard.",
    summary_entities: [
      "sensor.saros_20_set_status",
      "binary_sensor.roborock_program_ready",
      "binary_sensor.roborock_program_blocked",
      "input_boolean.roborock_busy",
    ],
    status_entities: [
      "sensor.saros_20_set_batterie",
      "sensor.saros_20_set_staubsauger_fehler",
      "input_text.roborock_current_program",
      "input_text.roborock_last_error",
    ],
    safe_actions: [
      {
        label: "Schlaf saugen",
        service: "script.roborock_run_named_program",
        data: { program_id: "schlaf_saug" },
        style: "primary",
      },
      {
        label: "Flur vac+mop",
        service: "script.roborock_run_named_program",
        data: { program_id: "flur_vac_mop" },
      },
      {
        label: "Wohn saugen",
        service: "script.roborock_run_named_program",
        data: { program_id: "wohn_saug" },
      },
    ],
    diagnostic_entities: [
      { entity: "input_datetime.roborock_busy_since" },
      { entity: "input_text.roborock_last_slot" },
      { entity: "input_text.roborock_last_job" },
      { entity: "input_text.roborock_last_program_sequence" },
    ],
    service_entities: ["input_boolean.roborock_schedule_enabled"],
    legacy_note:
      "Map-Card, Wartung und Wochenplan bleiben bis Phase 2 im bestehenden Roborock-Dashboard.",
  },
  {
    id: "weather",
    title: "Wetter",
    icon: "mdi:weather-partly-cloudy",
    description:
      "Verdichtete Lagekarte. Radar, DWD-Details und Spezialvisualisierungen bleiben vorerst im YAML-Dashboard.",
    summary_entities: [
      "sensor.hamburg_fu_temperatur",
      "sensor.hamburg_fu_wetterzustand",
      "sensor.hamburg_fu_precip_probability_next1h",
      "sensor.hamburg_fu_windgeschwindigkeit",
    ],
    status_entities: [
      "sensor.hamburg_fu_windboen",
      "sensor.hamburg_fu_sichtweite",
      "sensor.hamburg_fu_sonneneinstrahlung",
      "sensor.hamburg_fu_vorhersagezeit_local",
    ],
    safe_actions: [],
    diagnostic_entities: [
      { entity: "weather.hamburg_fu" },
      { entity: "sensor.hamburg_fu_precip_sum_24h" },
      { entity: "sensor.hamburg_fu_temp_next12h_max" },
      { entity: "sensor.hamburg_fu_temp_next12h_min" },
    ],
    legacy_note:
      "Radar, Weather Chart Card und Horizon Card bleiben zunaechst im bestehenden Wetter-Dashboard.",
  },
];

export function getModuleById(moduleId) {
  return MODULES.find((moduleConfig) => moduleConfig.id === moduleId) || MODULES[0];
}

const CARD_VERSION = "0.1.0";

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function friendlyNameForState(stateObj, entityId) {
  if (stateObj?.attributes?.friendly_name) {
    return stateObj.attributes.friendly_name;
  }

  return entityId.split(".").slice(1).join(".").replaceAll("_", " ");
}

function iconForState(stateObj) {
  return stateObj?.attributes?.icon || "mdi:checkbox-blank-circle-outline";
}

function iconMarkup(icon, className = "inline-icon") {
  return `<ha-icon class="${escapeHtml(className)}" icon="${escapeHtml(icon || "mdi:checkbox-blank-circle-outline")}"></ha-icon>`;
}

function formatTimestamp(rawValue) {
  if (!rawValue || rawValue === "unknown" || rawValue === "unavailable") {
    return rawValue;
  }

  const dateValue = new Date(rawValue);
  if (Number.isNaN(dateValue.getTime())) {
    return rawValue;
  }

  return dateValue.toLocaleString("de-DE", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatStateValue(entityId, stateObj) {
  if (!stateObj) {
    return "nicht verfuegbar";
  }

  if (entityId.startsWith("input_datetime.") || entityId.endsWith("_local")) {
    return formatTimestamp(stateObj.state);
  }

  const unit = stateObj.attributes?.unit_of_measurement;
  if (unit) {
    return `${stateObj.state} ${unit}`;
  }

  return stateObj.state;
}

function severityForState(entityId, stateObj) {
  if (!stateObj) {
    return "muted";
  }

  const state = stateObj.state;
  const warningStates = new Set(["on", "open", "opening", "unlocked", "problem", "error", "unavailable"]);

  if (
    entityId.includes("override") ||
    entityId.includes("blocked") ||
    entityId.includes("busy") ||
    entityId.includes("error") ||
    entityId.includes("fehler")
  ) {
    return warningStates.has(state) ? "warn" : "ok";
  }

  if (entityId.includes("batterie_ladung")) {
    const numericValue = Number.parseFloat(state);
    if (Number.isFinite(numericValue) && numericValue < 30) {
      return "warn";
    }
  }

  if (entityId.includes("precip_probability") || entityId.includes("windboen")) {
    const numericValue = Number.parseFloat(state);
    if (Number.isFinite(numericValue) && numericValue >= 70) {
      return "warn";
    }
  }

  if (state === "unknown" || state === "unavailable") {
    return "warn";
  }

  return "ok";
}

function renderEntityItem(hass, entityId) {
  const stateObj = hass.states[entityId];
  const severity = severityForState(entityId, stateObj);

  return `
    <div class="entity-row severity-${severity}">
      <div class="entity-leading">${iconMarkup(iconForState(stateObj), "entity-icon")}</div>
      <div class="entity-meta">
        <span class="entity-name">${escapeHtml(friendlyNameForState(stateObj, entityId))}</span>
        <span class="entity-subtitle">${escapeHtml(entityId)}</span>
      </div>
      <div class="entity-state">${escapeHtml(formatStateValue(entityId, stateObj))}</div>
    </div>
  `;
}

function renderConfiguredEntityItem(hass, entry) {
  if (!entry?.entity) {
    return "";
  }

  const stateObj = hass.states[entry.entity];
  if (!stateObj) {
    return "";
  }

  const severity = severityForState(entry.entity, stateObj);
  const label = entry.name || friendlyNameForState(stateObj, entry.entity);
  const subtitle = entry.subtitle || stateObj.attributes?.friendly_name || entry.entity;

  return `
    <div class="entity-row severity-${severity}">
      <div class="entity-leading">${iconMarkup(entry.icon || iconForState(stateObj), "entity-icon")}</div>
      <div class="entity-meta">
        <span class="entity-name">${escapeHtml(label)}</span>
        <span class="entity-subtitle">${escapeHtml(subtitle)}</span>
      </div>
      <div class="entity-state">${escapeHtml(formatStateValue(entry.entity, stateObj))}</div>
    </div>
  `;
}

function shortLabelForEntity(entityId) {
  if (entityId.includes("temperatur")) {
    return "Temperatur";
  }

  if (entityId.includes("luftfeuchtigkeit") || entityId.includes("_humidity")) {
    return "Feuchte";
  }

  if (entityId.includes("pressure")) {
    return "Luftdruck";
  }

  if (entityId.includes("beleucht") || entityId.includes("illuminance")) {
    return "Lux";
  }

  return entityId.split(".").pop().replaceAll("_", " ");
}

function renderMetricChip(hass, entityId) {
  const stateObj = hass.states[entityId];
  if (!stateObj) {
    return "";
  }

  return `
    <div class="metric-chip">
      <span class="metric-label">${escapeHtml(shortLabelForEntity(entityId))}</span>
      <span class="metric-value">${escapeHtml(formatStateValue(entityId, stateObj))}</span>
    </div>
  `;
}

function getRoomById(roomId) {
  return (ROOMS_CONFIG.rooms || []).find((roomConfig) => roomConfig.id === roomId) || ROOMS_CONFIG.rooms[0];
}

function renderRoomSelectorButton(hass, roomConfig, isActive, navigateToRooms = false) {
  const preview = (roomConfig.summary_entities || [])
    .map((entityId) => {
      const stateObj = hass.states[entityId];
      return stateObj ? formatStateValue(entityId, stateObj) : null;
    })
    .filter(Boolean)[0] || roomConfig.caption;

  const navigationAttribute = navigateToRooms ? ' data-page="rooms"' : "";

  return `
    <button class="room-selector ${isActive ? "is-active" : ""}" data-room="${escapeHtml(roomConfig.id)}"${navigationAttribute}>
      <span class="room-selector-title">${escapeHtml(roomConfig.title)}</span>
      <span class="room-selector-meta">${escapeHtml(preview || "Raum")}</span>
    </button>
  `;
}

function renderActiveRoomPanel(hass, roomConfig) {
  const summaryMarkup = (roomConfig.summary_entities || [])
    .map((entityId) => renderMetricChip(hass, entityId))
    .filter(Boolean)
    .join("");

  const detailMarkup = (roomConfig.detail_entities || [])
    .map((entry) => renderConfiguredEntityItem(hass, entry))
    .filter(Boolean)
    .join("");

  return `
    <div class="room-layout">
      <div class="room-hero-panel">
        <div class="room-panel-head">
          <div>
            <div class="panel-eyebrow">Aktiver Raum</div>
            <h2>${escapeHtml(roomConfig.title)}</h2>
            <p>${escapeHtml(roomConfig.caption || "Raumklima")}</p>
          </div>
          <div class="room-badge">${iconMarkup(roomConfig.icon, "room-panel-icon")}</div>
        </div>
        <div class="metric-grid">
          ${summaryMarkup || `<div class="empty-note">Keine Kerndaten sichtbar.</div>`}
        </div>
      </div>
      <div class="panel">
        <div class="panel-head-inline">
          <h3>Raumstatus</h3>
          <span class="panel-kicker">${escapeHtml(String((roomConfig.detail_entities || []).length))} Signale</span>
        </div>
        <div class="entity-list compact-list">
          ${detailMarkup || `<div class="empty-note">Keine kuratierten Raumsignale konfiguriert.</div>`}
        </div>
      </div>
    </div>
  `;
}

function renderDiagnosticEntry(hass, entry) {
  const stateObj = hass.states[entry.entity];
  const attributes = entry.attributes || [];
  const rows = [`<div class="diagnostic-head">${renderEntityItem(hass, entry.entity)}</div>`];

  for (const attributeName of attributes) {
    const attributeValue = stateObj?.attributes?.[attributeName];
    rows.push(`
      <div class="attribute-row">
        <span>${escapeHtml(attributeName)}</span>
        <span>${escapeHtml(attributeValue ?? "—")}</span>
      </div>
    `);
  }

  return `<div class="diagnostic-card">${rows.join("")}</div>`;
}
class SiekerOperatorHub extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this._config = {};
    this._hass = null;
    this._page = "home";
    this._moduleId = "heating";
    this._roomId = ROOMS_CONFIG.default_room_id || ROOMS_CONFIG.rooms[0]?.id || null;
  }

  setConfig(config) {
    this._config = config || {};
    this._page = this._config.default_page || "home";
    this._moduleId = this._config.default_module || this._moduleId;
    this._roomId = this._config.default_room || ROOMS_CONFIG.default_room_id || ROOMS_CONFIG.rooms[0]?.id || null;
    this._render();
  }

  set hass(hass) {
    this._hass = hass;
    this._render();
  }

  getCardSize() {
    return 16;
  }

  static getStubConfig() {
    return {
      type: "custom:sieker-operator-hub",
    };
  }

  _setPage(nextPage, moduleId = this._moduleId, roomId = this._roomId) {
    this._page = nextPage;
    this._moduleId = moduleId;
    this._roomId = roomId;
    this._render();
  }

  _pageLabel() {
    if (this._page === "rooms") {
      return "Raeume";
    }

    if (this._page === "module") {
      return getModuleById(this._moduleId).title;
    }

    return "Home";
  }

  async _runService(service, data) {
    if (!this._hass || !service) {
      return;
    }

    const [domain, action] = service.split(".");
    if (!domain || !action) {
      return;
    }

    await this._hass.callService(domain, action, data || {});
  }

  _bindEvents() {
    this.shadowRoot.querySelectorAll("[data-page]:not([data-room])").forEach((button) => {
      button.addEventListener("click", () => {
        const nextPage = button.getAttribute("data-page");
        const moduleId = button.getAttribute("data-module") || this._moduleId;
        this._setPage(nextPage, moduleId, this._roomId);
      });
    });

    this.shadowRoot.querySelectorAll("[data-room]").forEach((button) => {
      button.addEventListener("click", () => {
        const roomId = button.getAttribute("data-room") || this._roomId;
        const nextPage = button.getAttribute("data-page") || "rooms";
        this._setPage(nextPage, this._moduleId, roomId);
      });
    });

    this.shadowRoot.querySelectorAll("[data-service]").forEach((button) => {
      button.addEventListener("click", async () => {
        const service = button.getAttribute("data-service");
        const rawData = button.getAttribute("data-service-data");
        const payload = rawData ? JSON.parse(rawData) : {};
        await this._runService(service, payload);
      });
    });
  }

  _renderHome() {
    const statusCards = HOME_STATUS_ENTITIES.map((entityId) => {
      const stateObj = this._hass.states[entityId];
      const severity = severityForState(entityId, stateObj);

      return `
        <div class="status-card severity-${severity}">
          <div class="status-card-head">
            <div class="status-icon-wrap">${iconMarkup(iconForState(stateObj), "status-haicon")}</div>
            <span class="status-title">${escapeHtml(friendlyNameForState(stateObj, entityId))}</span>
          </div>
          <div class="status-value">${escapeHtml(formatStateValue(entityId, stateObj))}</div>
        </div>
      `;
    }).join("");

    const roomQuick = (ROOMS_CONFIG.rooms || [])
      .map((roomConfig) => renderRoomSelectorButton(this._hass, roomConfig, false, true))
      .join("");

    const moduleTiles = MODULES.map((moduleConfig) => `
      <button class="module-tile" data-page="module" data-module="${escapeHtml(moduleConfig.id)}">
        <div class="module-tile-head">
          ${iconMarkup(moduleConfig.icon, "nav-haicon")}
          <span class="nav-title">${escapeHtml(moduleConfig.title)}</span>
        </div>
        <span class="nav-desc">${escapeHtml(moduleConfig.description)}</span>
      </button>
    `).join("");

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>Hausstatus</h2>
          <p>Schneller Leitstand fuer Anwesenheit, Klima, Rolllaeden, Wetter und Roborock.</p>
        </div>
        <div class="status-grid">${statusCards}</div>
      </section>
      <section class="page-section">
        <div class="section-head">
          <h2>Raeume</h2>
          <p>Direkter Einstieg in die kuratierte Raumansicht statt langer Kartenwaende.</p>
        </div>
        <div class="room-selector-grid">${roomQuick}</div>
      </section>
      <section class="page-section">
        <div class="section-head">
          <h2>Fachmodule</h2>
          <p>Fachliche Bedienung bleibt ausdruecklich modulzentriert und script-sicher.</p>
        </div>
        <div class="module-grid">${moduleTiles}</div>
      </section>
    `;
  }

  _renderRooms() {
    const activeRoom = getRoomById(this._roomId);
    const roomSelector = (ROOMS_CONFIG.rooms || [])
      .map((roomConfig) => renderRoomSelectorButton(this._hass, roomConfig, roomConfig.id === activeRoom.id))
      .join("");

    const environmentMarkup = (ROOMS_CONFIG.environment_panel?.entities || [])
      .map((entry) => renderConfiguredEntityItem(this._hass, entry))
      .filter(Boolean)
      .join("");

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>${escapeHtml(ROOMS_CONFIG.title || "Raeume")}</h2>
          <p>${escapeHtml(ROOMS_CONFIG.description || "Raumklima und Umgebung.")}</p>
        </div>
        <div class="room-selector-grid">${roomSelector}</div>
      </section>
      <section class="page-section">
        ${renderActiveRoomPanel(this._hass, activeRoom)}
      </section>
      <section class="page-section">
        <div class="panel">
          <div class="panel-head-inline">
            <h3>${escapeHtml(ROOMS_CONFIG.environment_panel?.title || "Zugang und Umgebung")}</h3>
            <span class="panel-kicker">Umfeld</span>
          </div>
          <p class="panel-copy">${escapeHtml(ROOMS_CONFIG.environment_panel?.description || "")}</p>
          <div class="entity-list compact-list">
            ${environmentMarkup || `<div class="empty-note">Keine separaten Umgebungsdaten konfiguriert.</div>`}
          </div>
        </div>
      </section>
    `;
  }

  _renderModule() {
    const moduleConfig = getModuleById(this._moduleId);
    const summaryMarkup = moduleConfig.summary_entities.map((entityId) => renderEntityItem(this._hass, entityId)).join("");
    const statusMarkup = moduleConfig.status_entities.map((entityId) => renderEntityItem(this._hass, entityId)).join("");
    const actionMarkup = moduleConfig.safe_actions.length
      ? moduleConfig.safe_actions
          .map(
            (action) => `
              <button
                class="action-button action-${escapeHtml(action.style || "secondary")}" 
                data-service="${escapeHtml(action.service)}"
                data-service-data='${escapeHtml(JSON.stringify(action.data || {}))}'
              >
                ${escapeHtml(action.label)}
              </button>
            `,
          )
          .join("")
      : `<div class="empty-note">Im MVP sind hier noch keine direkten Safe-Aktionen hinterlegt.</div>`;

    const diagnosticMarkup = moduleConfig.diagnostic_entities.length
      ? moduleConfig.diagnostic_entities.map((entry) => renderDiagnosticEntry(this._hass, entry)).join("")
      : `<div class="empty-note">Keine Diagnoseeintraege konfiguriert.</div>`;

    const tuningMarkup = (moduleConfig.tuning_entities || []).length
      ? (moduleConfig.tuning_entities || []).map((entityId) => renderEntityItem(this._hass, entityId)).join("")
      : `<div class="empty-note">Tuning bleibt in diesem MVP schlank.</div>`;

    const serviceMarkup = (moduleConfig.service_entities || []).length
      ? (moduleConfig.service_entities || []).map((entityId) => renderEntityItem(this._hass, entityId)).join("")
      : `<div class="empty-note">Keine separaten Service-Entitaeten konfiguriert.</div>`;

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>${escapeHtml(moduleConfig.title)}</h2>
          <p>${escapeHtml(moduleConfig.description)}</p>
        </div>
        <div class="module-layout">
          <div class="module-column">
            <div class="panel">
              <h3>Zusammenfassung</h3>
              <div class="entity-list">${summaryMarkup}</div>
            </div>
            <div class="panel">
              <h3>Status</h3>
              <div class="entity-list">${statusMarkup}</div>
            </div>
            <div class="panel">
              <h3>Aktionen</h3>
              <div class="action-grid">${actionMarkup}</div>
            </div>
          </div>
          <div class="module-column">
            <div class="panel">
              <h3>Diagnose</h3>
              <div class="diagnostic-list">${diagnosticMarkup}</div>
            </div>
            <div class="panel">
              <h3>Tuning</h3>
              <div class="entity-list">${tuningMarkup}</div>
            </div>
            <div class="panel">
              <h3>Service</h3>
              <div class="entity-list">${serviceMarkup}</div>
            </div>
          </div>
        </div>
        <div class="legacy-note">${escapeHtml(moduleConfig.legacy_note || "")}</div>
      </section>
    `;
  }

  _render() {
    if (!this.shadowRoot) {
      return;
    }

    try {
      if (!this._hass) {
        this.shadowRoot.innerHTML = `
          <style>${this._styles()}</style>
          <ha-card>
            <div class="app-shell">
              <div class="loading-state">Warte auf Home Assistant Daten…</div>
            </div>
          </ha-card>
        `;
        return;
      }

      const activeModule = getModuleById(this._moduleId);
      const moduleButtons = MODULES.map((moduleConfig) => `
        <button
          class="module-chip ${moduleConfig.id === activeModule.id && this._page === "module" ? "is-active" : ""}"
          data-page="module"
          data-module="${escapeHtml(moduleConfig.id)}"
        >
          ${iconMarkup(moduleConfig.icon, "nav-haicon")}
          <span>${escapeHtml(moduleConfig.title)}</span>
        </button>
      `).join("");

      let pageMarkup = this._renderHome();
      if (this._page === "rooms") {
        pageMarkup = this._renderRooms();
      } else if (this._page === "module") {
        pageMarkup = this._renderModule();
      }

      this.shadowRoot.innerHTML = `
        <style>${this._styles()}</style>
        <ha-card>
          <div class="app-shell">
            <div class="shell-header">
              <div class="shell-copy">
                <div class="shell-eyebrow">Sieker Wohnung</div>
                <h1 class="shell-title">${escapeHtml(this._config.title || "Operator Hub")}</h1>
                <p>Kuratiertes Frontend fuer Hausstatus, Raumorientierung und sichere Fachmodule.</p>
              </div>
              <div class="page-badge">${escapeHtml(this._pageLabel())}</div>
            </div>
            <div class="nav-shell">
              <div class="segmented-nav">
                <button class="page-button ${this._page === "home" ? "is-active" : ""}" data-page="home">Home</button>
                <button class="page-button ${this._page === "rooms" ? "is-active" : ""}" data-page="rooms">Raeume</button>
              </div>
              <div class="module-rail">${moduleButtons}</div>
            </div>
            <div class="page-content">${pageMarkup}</div>
            <div class="footer-note">Sieker Operator Hub MVP ${escapeHtml(CARD_VERSION)} · Fokus auf Orientierung, nicht auf Registry-Rohdaten</div>
          </div>
        </ha-card>
      `;

      this._bindEvents();
    } catch (error) {
      console.error("Sieker Operator Hub: Render-Fehler.", error);
      this.shadowRoot.innerHTML = `
        <style>${this._styles()}</style>
        <ha-card>
          <div class="app-shell">
            <div class="loading-state">
              Frontend-Fehler im Operator Hub: ${escapeHtml(error?.message || "unbekannt")}
            </div>
          </div>
        </ha-card>
      `;
    }
  }

  _styles() {
    return `
      :host {
        display: block;
      }

      ha-card {
        overflow: hidden;
        border-radius: 28px;
      }

      ha-icon {
        color: currentColor;
      }

      .app-shell {
        display: grid;
        gap: 24px;
        padding: clamp(16px, 2vw, 28px);
        background:
          linear-gradient(180deg, rgba(33, 91, 185, 0.10) 0%, rgba(33, 91, 185, 0.02) 24%, transparent 60%),
          radial-gradient(circle at top right, rgba(26, 150, 115, 0.12), transparent 28%),
          var(--card-background-color);
      }

      .shell-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 18px;
      }

      .shell-copy {
        display: grid;
        gap: 8px;
      }

      .shell-eyebrow,
      .panel-eyebrow {
        color: var(--secondary-text-color);
        font-size: 0.74rem;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
      }

      .shell-title {
        margin: 0;
        font-size: clamp(1.45rem, 2vw, 2rem);
        line-height: 1.1;
      }

      .shell-copy p,
      .section-head p,
      .legacy-note,
      .footer-note,
      .empty-note,
      .loading-state,
      .panel-copy,
      .room-panel-head p {
        margin: 0;
        color: var(--secondary-text-color);
        line-height: 1.5;
      }

      .page-badge {
        padding: 10px 14px;
        border-radius: 999px;
        border: 1px solid rgba(56, 114, 212, 0.22);
        background: rgba(56, 114, 212, 0.12);
        font-weight: 700;
        white-space: nowrap;
      }

      .nav-shell {
        display: grid;
        gap: 12px;
        padding: 14px;
        border-radius: 20px;
        border: 1px solid rgba(127, 127, 127, 0.16);
        background: rgba(127, 127, 127, 0.05);
      }

      .segmented-nav,
      .module-rail,
      .action-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }

      .page-button,
      .module-chip,
      .room-selector,
      .module-tile,
      .action-button {
        appearance: none;
        border: 1px solid rgba(127, 127, 127, 0.20);
        border-radius: 16px;
        background: rgba(255, 255, 255, 0.04);
        color: var(--primary-text-color);
        cursor: pointer;
        font: inherit;
        transition: transform 120ms ease, border-color 120ms ease, background 120ms ease, box-shadow 120ms ease;
      }

      .page-button,
      .module-chip,
      .action-button {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 14px;
      }

      .page-button.is-active,
      .module-chip.is-active,
      .room-selector.is-active {
        border-color: rgba(56, 114, 212, 0.36);
        background: rgba(56, 114, 212, 0.14);
        box-shadow: inset 0 0 0 1px rgba(56, 114, 212, 0.10);
      }

      .page-button:hover,
      .module-chip:hover,
      .room-selector:hover,
      .module-tile:hover,
      .action-button:hover {
        transform: translateY(-1px);
      }

      .page-content,
      .page-section,
      .module-column,
      .entity-list,
      .diagnostic-list {
        display: grid;
        gap: 14px;
      }

      .section-head h2,
      .room-panel-head h2,
      .panel h3 {
        margin: 0;
      }

      .status-grid,
      .module-grid,
      .room-selector-grid,
      .metric-grid {
        display: grid;
        gap: 14px;
      }

      .status-grid {
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      }

      .module-grid {
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      }

      .room-selector-grid {
        grid-template-columns: repeat(auto-fit, minmax(146px, 1fr));
      }

      .metric-grid {
        grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
      }

      .status-card,
      .module-tile,
      .panel,
      .diagnostic-card,
      .room-hero-panel {
        border: 1px solid rgba(127, 127, 127, 0.18);
        border-radius: 22px;
        background: rgba(255, 255, 255, 0.05);
        padding: 16px;
      }

      .status-card {
        display: grid;
        gap: 12px;
        min-height: 126px;
      }

      .status-card-head,
      .module-tile-head,
      .panel-head-inline,
      .room-panel-head {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 12px;
      }

      .module-tile {
        display: grid;
        gap: 10px;
        text-align: left;
      }

      .status-icon-wrap,
      .room-badge,
      .entity-leading {
        display: grid;
        place-items: center;
        flex: 0 0 auto;
        border-radius: 14px;
        background: rgba(56, 114, 212, 0.10);
      }

      .status-icon-wrap,
      .room-badge {
        width: 44px;
        height: 44px;
      }

      .entity-leading {
        width: 34px;
        height: 34px;
        border-radius: 12px;
      }

      .inline-icon,
      .status-haicon,
      .nav-haicon,
      .entity-icon,
      .room-panel-icon {
        --mdc-icon-size: 20px;
      }

      .status-title,
      .nav-title,
      .room-selector-title,
      .entity-name {
        font-weight: 700;
      }

      .nav-desc,
      .room-selector-meta,
      .entity-subtitle,
      .panel-kicker {
        color: var(--secondary-text-color);
      }

      .status-value,
      .metric-value,
      .entity-state {
        font-weight: 700;
      }

      .status-value {
        font-size: 1.18rem;
      }

      .room-selector {
        display: grid;
        gap: 4px;
        padding: 12px 14px;
        text-align: left;
      }

      .room-layout,
      .module-layout {
        display: grid;
        gap: 14px;
        grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr);
      }

      .room-hero-panel {
        display: grid;
        gap: 18px;
      }

      .metric-chip {
        display: grid;
        gap: 4px;
        padding: 12px 14px;
        border-radius: 16px;
        border: 1px solid rgba(127, 127, 127, 0.16);
        background: rgba(255, 255, 255, 0.05);
      }

      .metric-label {
        color: var(--secondary-text-color);
        font-size: 0.76rem;
        font-weight: 700;
        letter-spacing: 0.06em;
        text-transform: uppercase;
      }

      .entity-row {
        display: grid;
        grid-template-columns: auto minmax(0, 1fr) auto;
        align-items: center;
        gap: 12px;
        padding: 12px 14px;
        border-radius: 16px;
        border: 1px solid rgba(127, 127, 127, 0.12);
        background: rgba(255, 255, 255, 0.04);
      }

      .entity-meta {
        display: grid;
        gap: 3px;
        min-width: 0;
      }

      .entity-subtitle {
        font-size: 0.82rem;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .entity-state {
        text-align: right;
      }

      .severity-warn {
        border-color: rgba(201, 79, 79, 0.24);
        background: rgba(201, 79, 79, 0.08);
      }

      .severity-ok {
        border-color: rgba(74, 152, 109, 0.20);
      }

      .severity-muted {
        opacity: 0.88;
      }

      .action-primary {
        border-color: rgba(56, 114, 212, 0.36);
        background: rgba(56, 114, 212, 0.14);
      }

      .action-warn {
        border-color: rgba(201, 79, 79, 0.30);
        background: rgba(201, 79, 79, 0.12);
      }

      .attribute-row {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        padding-top: 8px;
        font-size: 0.88rem;
        color: var(--secondary-text-color);
      }

      .footer-note {
        font-size: 0.82rem;
      }

      @media (max-width: 980px) {
        .shell-header,
        .room-layout,
        .module-layout,
        .panel-head-inline {
          grid-template-columns: 1fr;
          flex-direction: column;
        }

        .page-badge {
          align-self: flex-start;
        }
      }

      @media (max-width: 720px) {
        .app-shell {
          padding: 14px;
        }

        .status-grid,
        .module-grid,
        .room-selector-grid,
        .metric-grid {
          grid-template-columns: 1fr;
        }

        .entity-row {
          grid-template-columns: auto minmax(0, 1fr);
        }

        .entity-state {
          grid-column: 2;
          text-align: left;
        }
      }
    `;
  }
}
if (!customElements.get("sieker-operator-hub")) {
  customElements.define("sieker-operator-hub", SiekerOperatorHub);
}

window.customCards = window.customCards || [];
if (!window.customCards.some((card) => card.type === "sieker-operator-hub")) {
  window.customCards.push({
    type: "sieker-operator-hub",
    name: "Sieker Operator Hub",
    description: "MVP custom card shell for the next operator-focused dashboard application.",
  });
}




